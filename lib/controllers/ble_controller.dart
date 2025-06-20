import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  // Danh sách thiết bị BLE đã quét được
  RxList<ScanResult> scannedDevices = <ScanResult>[].obs;

  // Thiết bị hiện tại đang kết nối
  Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);

  // Danh sách dịch vụ đã khám phá được từ thiết bị
  RxList<BluetoothService> discoveredServices = <BluetoothService>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Lắng nghe kết quả quét và cập nhật danh sách thiết bị
    FlutterBluePlus.scanResults.listen((results) {
      scannedDevices.assignAll(results);
      for (var result in results) {
        print("📶 Đã tìm thấy: ${result.device.name} (${result.device.id.id})");
      }
    });
  }

  // Xin quyền BLE cần thiết
  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();
  }

  // Quét các thiết bị BLE xung quanh
  Future<void> scanDevices() async {
    await requestPermissions();

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      print("⚠️ Bluetooth chưa được bật!");
      return;
    }

    scannedDevices.clear();

    print("🚀 Bắt đầu quét thiết bị BLE...");
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  // Kết nối tới thiết bị BLE
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      connectedDevice.value = device;

      // Theo dõi trạng thái kết nối
      device.state.listen((state) async {
        if (state == BluetoothDeviceState.connecting) {
          print("🔌 Đang kết nối với: ${device.name}");
        } else if (state == BluetoothDeviceState.connected) {
          print("✅ Đã kết nối: ${device.name}");

          // Đợi 1s trước khi khám phá dịch vụ (fix một số thiết bị BLE cần delay)
          await Future.delayed(const Duration(seconds: 1));
          await discoverServices(device);
        } else if (state == BluetoothDeviceState.disconnected) {
          print("❌ Mất kết nối: ${device.name}");
        }
      });
    } catch (e) {
      print("❗ Lỗi khi kết nối thiết bị: $e");
    }
  }

  // Ngắt kết nối thiết bị hiện tại
  Future<void> disconnectDevice() async {
    final device = connectedDevice.value;
    if (device != null) {
      await device.disconnect();
      connectedDevice.value = null;
      discoveredServices.clear();
      print("🔌 Thiết bị đã ngắt kết nối");
    }
  }

  // Khám phá các service & characteristic của thiết bị
  Future<void> discoverServices(BluetoothDevice device) async {
    try {
      print("🔍 Đang khám phá dịch vụ từ: ${device.name}");
      List<BluetoothService> services = await device.discoverServices();
      discoveredServices.assignAll(services);
      print("✅ Tìm thấy ${services.length} dịch vụ");

      for (var service in services) {
        print("🧪 Service: ${service.uuid}");
        for (var characteristic in service.characteristics) {
          print("   🔹 Characteristic: ${characteristic.uuid} | properties: ${characteristic.properties}");
        }
      }
    } catch (e) {
      print("⚠️ Lỗi khi khám phá dịch vụ: $e");
    }
  }
}
