import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/ble_controller.dart';

class BleView extends StatelessWidget {
  final BleController controller = Get.put(BleController());
  final RxBool showServices = false.obs;
  final RxBool isScanning = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thiết bị BLE gần đây"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Nút quét thiết bị
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: Obx(() => isScanning.value
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : Icon(Icons.search)),
              label: Obx(() =>
                  Text(isScanning.value ? "Đang quét..." : "Quét thiết bị")),
              onPressed: () async {
                isScanning.value = true;
                await controller.scanDevices();
                await Future.delayed(Duration(seconds: 16));
                isScanning.value = false;
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
              ),
            ),
          ),

          // Thông tin thiết bị đã kết nối
          Obx(() {
            final device = controller.connectedDevice.value;
            if (device == null) return SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Card(
                color: Colors.green[50],
                child: ListTile(
                  title: Text("Đang kết nối với: ${device.name}"),
                  subtitle: Text("ID: ${device.id.id}"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await controller.discoverServices(device);
                          showServices.value = true;
                        },
                        child: Text("Hiển thị dịch vụ"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.disconnectDevice();
                          showServices.value = false;
                        },
                        child: Text("Ngắt kết nối"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Danh sách thiết bị quét được
          Expanded(
            child: Obx(() {
              final devices = controller.scannedDevices;

              if (isScanning.value) {
                return Center(child: Text("🔍 Đang quét thiết bị..."));
              }

              if (devices.isEmpty) {
                return Center(child: Text("⚠️ Không tìm thấy thiết bị nào"));
              }

              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final result = devices[index];
                  final device = result.device;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        device.name.isNotEmpty
                            ? device.name
                            : "Không có tên",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                      Text("ID: ${device.id.id}\nRSSI: ${result.rssi}"),
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        child: Text("Kết nối"),
                        onPressed: () async {
                          showServices.value = false;
                          await controller.connectToDevice(device);
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Hiển thị danh sách dịch vụ đã khám phá
          Obx(() {
            final services = controller.discoveredServices;
            if (!showServices.value || services.isEmpty)
              return SizedBox.shrink();

            return SizedBox(
              height: 250, // 👈 Chỉ định chiều cao cố định để tránh overflow
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, serviceIndex) {
                    final service = services[serviceIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🧪 Service: ${service.uuid}"),
                        ...service.characteristics.map(
                              (c) => Padding(
                            padding:
                            const EdgeInsets.only(left: 16.0, top: 4),
                            child: Text(
                                "🔹 Characteristic: ${c.uuid} | properties: ${c.properties}"),
                          ),
                        ),
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
    );
  }
}
