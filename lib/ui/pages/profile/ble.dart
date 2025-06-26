import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/ble_controller.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:ui';
import 'package:collection/collection.dart';

class BleView extends StatefulWidget {
  @override
  State<BleView> createState() => _BleViewState();
}

class _BleViewState extends State<BleView> {
  final BleController controller = Get.put(BleController());
  final RxBool showServices = false.obs;
  final RxBool isScanning = false.obs;
  int deviceListKey = 0;
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby BLE Devices"), 
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            FutureBuilder<List<Map<String, String>>>(
              key: ValueKey(deviceListKey),
              future: controller.loadConnectedDevices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox.shrink();
                }
                final devices = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Previously Connected Devices:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    ...devices.map((d) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(Icons.bluetooth),
                        title: Text(d['name'] ?? '', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        subtitle: Text(d['id'] ?? '', style: TextStyle(color: Colors.black54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              child: Text('Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final scanned = controller.scannedDevices.firstWhereOrNull(
                                  (s) => s.device.id.id == d['id'],
                                );
                                if (scanned != null) {
                                  await controller.connectToDevice(scanned.device);
                                } else {
                                  Get.snackbar('Device not found', 'Please turn on the device and scan again.');
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Device'),
                                    content: Text('Are you sure you want to delete this device from history?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await controller.removeConnectedDevice(d['id']!);
                                  setState(() {
                                    deviceListKey++;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                    Divider(),
                  ],
                );
              },
            ),
            // Nút để bắt đầu quá trình quét thiết bị BLE
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: ElevatedButton.icon(
                  // Hiển thị loading nếu đang quét, icon tìm kiếm nếu không
                  icon: Obx(() => isScanning.value
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Icon(Icons.search)),
                  // Hiển thị văn bản theo trạng thái quét
                  label: Obx(() =>
                      Text(isScanning.value ? "Scanning..." : "Scan Devices")),
                  // Hành động khi nhấn nút: bắt đầu quét, sau 5s thì tắt
                  onPressed: () async {
                    setState(() {
                      isScanning.value = true;
                      hasScanned = false;
                    });
                    await controller.scanDevices();
                    await Future.delayed(Duration(seconds: 5));
                    setState(() {
                      isScanning.value = false;
                      hasScanned = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            if (!hasScanned && !isScanning.value)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    'No devices found. Please press Scan Devices.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

            // Nếu có thiết bị đang kết nối thì hiển thị thông tin thiết bị đó
            Obx(() {
              final device = controller.connectedDevice.value;
              if (device == null) return SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.bluetooth_connected, color: Colors.blue, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.name.isNotEmpty ? device.name : "No name",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                              ),
                              Text(
                                "ID: ${device.id.id}",
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: "Show Services",
                          icon: Icon(Icons.info_outline, color: Colors.blueAccent),
                          onPressed: () async {
                            await controller.discoverServices(device);
                            showServices.value = true;
                          },
                        ),
                        IconButton(
                          tooltip: "Disconnect",
                          icon: Icon(Icons.close, color: Colors.redAccent),
                          onPressed: () {
                            controller.disconnectDevice();
                            showServices.value = false;
                            setState(() {
                              hasScanned = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Danh sách các thiết bị BLE được quét
            Obx(() {
              final device = controller.connectedDevice.value;
              if (device != null || !hasScanned || isScanning.value) return SizedBox.shrink(); // Đã kết nối hoặc chưa scan thì ẩn danh sách quét
              final devices = controller.scannedDevices;

              if (devices.isEmpty) {
                return Center(child: Text("⚠️ No devices found", style: TextStyle(color: Colors.black87, fontSize: 16)));
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final result = devices[index];
                    final device = result.device;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        title: Text(
                          device.name.isNotEmpty
                              ? device.name
                              : "No name", // Nếu thiết bị không có tên thì hiển thị thông báo
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),  
                        subtitle: Text("ID: ${device.id.id}\nRSSI: ${result.rssi}", style: TextStyle(color: Colors.black54)),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          child: Text("Connect", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            showServices.value = false; // Ẩn danh sách service cũ nếu có
                            await controller.connectToDevice(device); // Gọi kết nối đến thiết bị được chọn
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Hiển thị danh sách các dịch vụ BLE đã khám phá từ thiết bị
            Obx(() {
              final services = controller.discoveredServices;
              if (!showServices.value || services.isEmpty)
                return SizedBox.shrink(); // Nếu chưa kết nối hoặc chưa có service thì không hiển thị

              return SizedBox(
                height: 250, // 👈 Giới hạn chiều cao để tránh tràn màn hình
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, serviceIndex) {
                      final service = services[serviceIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🧪 Service: ${service.uuid}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)), //  Service: ${service.uuid}
                          ...service.characteristics.map(
                                (c) => Padding(
                              padding:
                              const EdgeInsets.only(left: 16.0, top: 4),
                              child: Text(
                                  "🔹 Characteristic: ${c.uuid} | properties: ${c.properties}", style: TextStyle(color: Colors.black54)),
                            ),
                          ), // Lặp và hiển thị các đặc tính của service    
                          SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}