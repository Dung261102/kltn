import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Thư viện giao tiếp BLE
import 'package:get/get.dart'; // Quản lý trạng thái reactive
import 'package:permission_handler/permission_handler.dart'; // Xin quyền truy cập

class BleController extends GetxController {
  // Danh sách thiết bị BLE đã quét được (dùng Rx để tự động cập nhật UI khi thay đổi)
  RxList<ScanResult> scannedDevices = <ScanResult>[].obs;

  // Thiết bị hiện tại đang kết nối (Rx cho phép theo dõi thay đổi)
  Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);

  // Danh sách dịch vụ đã khám phá được từ thiết bị
  RxList<BluetoothService> discoveredServices = <BluetoothService>[].obs;

  // Thêm RxList để lưu lịch sử glucose real-time
  RxList<({DateTime time, int value})> glucoseHistory = <({DateTime time, int value})>[].obs;

  // UUID mẫu cho service và characteristic glucose
  static const String glucoseServiceUuid = '12345678-1234-5678-1234-56789abcdef0';
  static const String glucoseCharUuid = '12345678-1234-5678-1234-56789abcdef1';

  @override
  void onInit() {
    super.onInit();

    // Đăng ký lắng nghe kết quả quét thiết bị BLE
    FlutterBluePlus.scanResults.listen((results) {
      scannedDevices.assignAll(results); // Cập nhật danh sách thiết bị đã quét được
      for (var result in results) {
        print("\uD83D\uDCF6 Đã tìm thấy: \${result.device.name} (\${result.device.id.id})");
      }
    });

    // Lắng nghe khi connectedDevice thay đổi để tự động subscribe
    ever(connectedDevice, (BluetoothDevice? device) async {
      if (device != null) {
        // Đợi khám phá dịch vụ xong rồi subscribe
        await Future.delayed(const Duration(seconds: 2));
        await subscribeGlucoseCharacteristic();
      }
    });
  }

  // Hàm yêu cầu các quyền cần thiết để dùng BLE
  Future<void> requestPermissions() async {
    await [
      Permission.location, // Một số thiết bị yêu cầu quyền định vị khi quét BLE
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();
  }

  // Hàm bắt đầu quét thiết bị BLE xung quanh
  Future<void> scanDevices() async {
    await requestPermissions(); // Đảm bảo quyền được cấp

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      print("⚠️ Bluetooth chưa được bật!");
      return;
    }

    scannedDevices.clear(); // Xoá kết quả cũ trước khi quét mới

    print("\uD83D\uDE80 Bắt đầu quét thiết bị BLE...");
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  // Hàm kết nối đến một thiết bị BLE đã chọn
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      connectedDevice.value = device; // Gán thiết bị đã kết nối

      // Lắng nghe trạng thái kết nối
      device.state.listen((state) async {
        if (state == BluetoothDeviceState.connecting) {
          print("\uD83D\uDD0C Đang kết nối với: \${device.name}");
        } else if (state == BluetoothDeviceState.connected) {
          print("✅ Đã kết nối: \${device.name}");

          // Đợi một chút trước khi khám phá dịch vụ
          await Future.delayed(const Duration(seconds: 1));
          await discoverServices(device);
        } else if (state == BluetoothDeviceState.disconnected) {
          print("❌ Mất kết nối: \${device.name}");
        }
      });
    } catch (e) {
      print("❗ Lỗi khi kết nối thiết bị: \$e");
    }
  }

  // Ngắt kết nối khỏi thiết bị hiện tại
  Future<void> disconnectDevice() async {
    final device = connectedDevice.value;
    if (device != null) {
      await device.disconnect();
      connectedDevice.value = null; // Reset trạng thái
      discoveredServices.clear();
      print("\uD83D\uDD0C Thiết bị đã ngắt kết nối");
    }
  }

  // Hàm khám phá các service và characteristic của thiết bị BLE
  Future<void> discoverServices(BluetoothDevice device) async {
    try {
      print("\uD83D\uDD0D Đang khám phá dịch vụ từ: \${device.name}");
      List<BluetoothService> services = await device.discoverServices();
      discoveredServices.assignAll(services); // Lưu danh sách dịch vụ vào state
      print("✅ Tìm thấy \${services.length} dịch vụ");

      for (var service in services) {
        print("\uD83E\uDDEA Service: \${service.uuid}");
        for (var characteristic in service.characteristics) {
          print("   \uD83D\uDD39 Characteristic: \${characteristic.uuid} | properties: \${characteristic.properties}");
        }
      }
    } catch (e) {
      print("⚠️ Lỗi khi khám phá dịch vụ: \$e");
    }
  }

  // Hàm subscribe BLE characteristic để nhận dữ liệu glucose real-time
  Future<void> subscribeGlucoseCharacteristic({
    String? serviceUuid,
    String? charUuid,
  }) async {
    final device = connectedDevice.value;
    if (device == null) return;
    final sUuid = serviceUuid ?? glucoseServiceUuid;
    final cUuid = charUuid ?? glucoseCharUuid;
    final services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString().toLowerCase() == sUuid.toLowerCase()) {
        for (var c in service.characteristics) {
          if (c.uuid.toString().toLowerCase() == cUuid.toLowerCase()) {
            await c.setNotifyValue(true);
            c.value.listen((value) {
              if (value.isNotEmpty) {
                // Giả sử dữ liệu gửi về là 1 byte int (mg/dL)
                final glucose = value[0];
                glucoseHistory.insert(0, (time: DateTime.now(), value: glucose));
                print('🔔 Glucose notify: $glucose mg/dL');
              }
            });
          }
        }
      }
    }
  }

  Future<void> doMeasureGlucose() async {
    // Nếu thiết bị IoT cần nhận lệnh đo, gửi lệnh ở đây (ví dụ ghi vào characteristic control)
    // Ở đây giả lập: chỉ chờ 2s, thiết bị sẽ notify giá trị mới
    await Future.delayed(const Duration(seconds: 2));
    // Nếu thiết bị tự động notify, không cần làm gì thêm
    // Nếu muốn test, có thể thêm giá trị giả lập:
    // glucoseHistory.insert(0, (time:s DateTime.now(), value: 80 + Random().nextInt(40)));
  }
}
