import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../rest/rest_api.dart';
import '../services/glucose_service.dart';

class BleController extends GetxController {
  RxList<ScanResult> scannedDevices = <ScanResult>[].obs;
  Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  RxList<BluetoothService> discoveredServices = <BluetoothService>[].obs;
  RxList<({DateTime time, int value})> glucoseHistory = <({DateTime time, int value})>[].obs;

  static const String glucoseServiceUuid = '12345678-1234-5678-1234-56789abcdef0';
  static const String glucoseCharUuid = '12345678-1234-5678-1234-56789abcdef1';

  final GlucoseService _glucoseService = GlucoseService();

  @override
  void onInit() {
    super.onInit();

    FlutterBluePlus.scanResults.listen((results) {
      scannedDevices.assignAll(results);
      for (var result in results) {
        print("📡 Đã tìm thấy: ${result.device.name} (${result.device.id.id})");
      }
    });

    ever(connectedDevice, (BluetoothDevice? device) async {
      if (device != null) {
        await Future.delayed(const Duration(seconds: 2));
        await subscribeGlucoseCharacteristic();
      }
    });

    // Load glucose history khi khởi tạo
    _loadGlucoseHistory();
  }

  // Load glucose history từ database
  Future<void> _loadGlucoseHistory() async {
    try {
      final history = await getGlucoseHistory();
      glucoseHistory.assignAll(history);
      print('📊 Loaded ${history.length} glucose records from database');
    } catch (e) {
      print('❌ Error loading glucose history: $e');
    }
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();
  }

  Future<void> scanDevices() async {
    await requestPermissions();
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      print("⚠️ Bluetooth chưa được bật!");
      return;
    }

    scannedDevices.clear();
    print("🔍 Bắt đầu quét thiết bị BLE...");
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      connectedDevice.value = device;
      await saveConnectedDevice(device);

      device.state.listen((state) async {
        if (state == BluetoothDeviceState.connected) {
          print("✅ Đã kết nối: ${device.name}");
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

  Future<void> disconnectDevice() async {
    final device = connectedDevice.value;
    if (device != null) {
      await device.disconnect();
      connectedDevice.value = null;
      discoveredServices.clear();
      print("🔌 Thiết bị đã ngắt kết nối");
    }
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    try {
      print("🔍 Đang khám phá dịch vụ từ: ${device.name}");
      List<BluetoothService> services = await device.discoverServices();
      discoveredServices.assignAll(services);
      print("✅ Tìm thấy ${services.length} dịch vụ");

      for (var service in services) {
        print("🧬 Service: ${service.uuid}");
        for (var characteristic in service.characteristics) {
          print("   🔹 Characteristic: ${characteristic.uuid} | properties: ${characteristic.properties}");
        }
      }
    } catch (e) {
      print("⚠️ Lỗi khi khám phá dịch vụ: $e");
    }
  }

  Future<void> subscribeGlucoseCharacteristic({
    String? serviceUuid,
    String? charUuid,
  }) async {
    final device = connectedDevice.value;
    if (device == null) {
      print("⚠️ Không có thiết bị nào đang kết nối");
      return;
    }

    final sUuid = serviceUuid ?? glucoseServiceUuid;
    final cUuid = charUuid ?? glucoseCharUuid;

    try {
      final services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == sUuid.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == cUuid.toLowerCase()) {
              // Bật notify
              await characteristic.setNotifyValue(true);
              // ⏱️ Delay 1 giây sau khi bật notify
              await Future.delayed(const Duration(seconds: 1));
              // await Future.delayed(const Duration(milliseconds: 200));

              print("📡 Đã subscribe characteristic: ${characteristic.uuid}");
              print("🟢 Đang lắng nghe dữ liệu từ BLE...");

              // Lắng nghe dữ liệu real-time từ thiết bị
              characteristic.lastValueStream.listen((value) async {
                print("📦 Nhận dữ liệu BLE: $value");

                if (value.isEmpty) {
                  print("⚠️ Dữ liệu BLE rỗng, bỏ qua");
                  return;
                }

                try {
                  final jsonString = utf8.decode(value);
                  print("📥 Chuỗi JSON nhận được: $jsonString");

                  if (!jsonString.trim().startsWith('{') || !jsonString.trim().endsWith('}')) {
                    print("⚠️ Không phải JSON hợp lệ: $jsonString");
                    return;
                  }

                  final Map<String, dynamic> decoded = jsonDecode(jsonString);
                  final glucose = decoded['glucose'];

                  if (glucose is int) {
                    glucoseHistory.insert(0, (time: DateTime.now(), value: glucose));
                    print("🔔 Glucose mới: $glucose mg/dL");

                    // Lưu dữ liệu vào database local và đồng bộ với server
                    await _glucoseService.saveGlucoseData(
                      glucose,
                      connectedDevice.value?.id.id ?? 'unknown-device',
                    );
                    
                    // Refresh glucose history từ database để đảm bảo dữ liệu đồng bộ
                    await _refreshGlucoseHistory();
                  } else {
                    print("⚠️ Không tìm thấy hoặc sai kiểu dữ liệu glucose trong JSON");
                  }
                } catch (e) {
                  print("❌ Lỗi khi phân tích JSON từ BLE: $e");
                }
              });

              return; // Ngừng sau khi đã subscribe
            }
          }
        }
      }

      print("⚠️ Không tìm thấy characteristic có UUID phù hợp");
    } catch (e) {
      print("❗ Lỗi trong quá trình subscribe BLE: $e");
    }
  }

  // Lấy dữ liệu glucose từ database
  Future<List<({DateTime time, int value})>> getGlucoseHistory() async {
    try {
      final glucoseDataList = await _glucoseService.getUserGlucoseData();
      return glucoseDataList.map((data) => (
        time: data.timestamp,
        value: data.glucoseValue,
      )).toList();
    } catch (e) {
      print("❌ Error getting glucose history: $e");
      return [];
    }
  }

  // Đồng bộ thủ công
  Future<void> manualSync() async {
    await _glucoseService.manualSync();
  }

  Future<void> doMeasureGlucose() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  // Refresh glucose history từ database
  Future<void> _refreshGlucoseHistory() async {
    try {
      final history = await getGlucoseHistory();
      glucoseHistory.assignAll(history);
      print('🔄 Refreshed glucose history: ${history.length} records');
    } catch (e) {
      print('❌ Error refreshing glucose history: $e');
    }
  }

  Future<void> saveConnectedDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final devices = prefs.getStringList('ble_devices') ?? [];
    final deviceInfo = '${device.id.id}|${device.name}';
    if (!devices.contains(deviceInfo)) {
      devices.add(deviceInfo);
      await prefs.setStringList('ble_devices', devices);
    }
  }

  Future<List<Map<String, String>>> loadConnectedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devices = prefs.getStringList('ble_devices') ?? [];
    return devices.map((e) {
      final parts = e.split('|');
      return {'id': parts[0], 'name': parts.length > 1 ? parts[1] : ''};
    }).toList();
  }

  Future<void> removeConnectedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final devices = prefs.getStringList('ble_devices') ?? [];
    devices.removeWhere((e) => e.startsWith(deviceId + '|'));
    await prefs.setStringList('ble_devices', devices);
  }
}
