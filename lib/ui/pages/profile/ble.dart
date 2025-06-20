import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/ble_controller.dart';

class BleView extends StatelessWidget {
  // Tạo và đăng ký controller BLE với GetX để quản lý trạng thái toàn cục
  final BleController controller = Get.put(BleController());
  // Trạng thái cho biết có hiển thị danh sách dịch vụ không
  final RxBool showServices = false.obs;
  // Trạng thái cho biết có đang quét BLE không
  final RxBool isScanning = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thiết bị BLE gần đây"), // Tiêu đề thanh điều hướng
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Nút để bắt đầu quá trình quét thiết bị BLE
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                  Text(isScanning.value ? "Đang quét..." : "Quét thiết bị")),
              // Hành động khi nhấn nút: bắt đầu quét, sau 16s thì tắt
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

          // Nếu có thiết bị đang kết nối thì hiển thị thông tin thiết bị đó
          Obx(() {
            final device = controller.connectedDevice.value;
            if (device == null) return SizedBox.shrink(); // Không có thì ẩn

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Card(
                color: Colors.green[50], // Nền nhẹ nhàng cho phần thiết bị kết nối
                child: ListTile(
                  title: Text("Đang kết nối với: ${device.name}"),
                  subtitle: Text("ID: ${device.id.id}"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      // Nút để hiển thị các dịch vụ của thiết bị
                      ElevatedButton(
                        onPressed: () async {
                          await controller.discoverServices(device);
                          showServices.value = true;
                        },
                        child: Text("Hiển thị dịch vụ"),
                      ),
                      // Nút để ngắt kết nối
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

          // Danh sách các thiết bị BLE được quét
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
                            : "Không có tên", // Nếu thiết bị không có tên thì hiển thị thông báo
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                      Text("ID: ${device.id.id}\nRSSI: ${result.rssi}"), // Hiển thị ID và độ mạnh tín hiệu
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        child: Text("Kết nối"),
                        onPressed: () async {
                          showServices.value = false; // Ẩn danh sách service cũ nếu có
                          await controller.connectToDevice(device); // Gọi kết nối đến thiết bị được chọn
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),

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
                        Text("🧪 Service: ${service.uuid}"), // Hiển thị UUID của service
                        ...service.characteristics.map(
                              (c) => Padding(
                            padding:
                            const EdgeInsets.only(left: 16.0, top: 4),
                            child: Text(
                                "🔹 Characteristic: ${c.uuid} | properties: ${c.properties}"),
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
    );
  }
}