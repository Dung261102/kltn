
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/ui/pages/profile/profile_menu.dart';
import 'package:glucose_real_time/services/notification_services.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:glucose_real_time/ui/widgets/common_appbar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'UpdateProfileScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final NotifyHelper notifyHelper = NotifyHelper();

  // Placeholder cho tên và ID thiết bị (có thể set sau từ Node.js hoặc phía logic)
  String? savedDeviceName;
  String? savedDeviceId;

  // Tên người dùng hiện tại
  String userName = "Nguyen Dung";
  // chưa fix lỗi bấm vo username cũng chuyển màn hình

  // Hàm gọi UI chọn thiết bị - logic sẽ xử lý sau
  void _onAddDevicePressed() {
    // TODO: Gắn kết với logic tìm và kết nối thiết bị (Node.js hoặc logic Flutter riêng)
  }

  // Hàm gọi khi người dùng xoá thiết bị - xử lý sau
  void _onClearDevicePressed() {

    // TODO: Gắn kết logic xoá thiết bị đã lưu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildProfileHeader(),             // Bấm avatar sẽ điều hướng đến chỉnh sửa
            const SizedBox(height: 20),
            _buildDeviceInfo(),                // UI thêm thiết bị và thông tin thiết bị
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            _buildMenuOptions(),               // Danh sách chức năng khác
          ],
        ),
      ),
    );
  }

  // UI hiển thị thông tin thiết bị và các nút tương tác
  Widget _buildDeviceInfo() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _onAddDevicePressed,
          child: const Text("Add Device"),
        ),
        if (savedDeviceName != null && savedDeviceId != null) ...[
          const SizedBox(height: 10),
          Text("Thiết bị đã kết nối:", style: Theme.of(context).textTheme.bodyMedium),
          Text("$savedDeviceName ($savedDeviceId)", style: const TextStyle(color: Colors.blueAccent)),
          TextButton(
            onPressed: _onClearDevicePressed,
            child: const Text("Xoá thiết bị đã lưu", style: TextStyle(color: Colors.red)),
          ),
        ],
      ],
    );
  }

  // Avatar + tên người dùng, có thể bấm để chỉnh sửa profile
  Widget _buildProfileHeader() {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(() => const UpdateProfileScreen());
        if (result != null && result is String) {
          setState(() {
            userName = result;
          });
        }
      },
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: const Image(
                    image: AssetImage("assets/images/profile/avatar.jpg"),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                  ),
                  child: const Icon(
                    LineAwesomeIcons.pen_fancy_solid,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            userName,
            style: headingStyle,
          ),
        ],
      ),
    );
  }

  // Danh sách các lựa chọn trong trang profile
  Widget _buildMenuOptions() {
    return Column(
      children: [
        ProfileMenuWidget(
          title: 'Settings',
          icon: LineAwesomeIcons.cog_solid,
          onPress: () {},
        ),
        ProfileMenuWidget(
          title: 'Profile',
          icon: LineAwesomeIcons.user,
          onPress: () {},
        ),
        ProfileMenuWidget(
          title: 'Privacy Policy',
          icon: LineAwesomeIcons.key_solid,
          onPress: () {},
        ),
        const Divider(color: Colors.black),
        const SizedBox(height: 10),
        ProfileMenuWidget(
          title: 'Help',
          icon: LineAwesomeIcons.question_circle,
          onPress: () {},
        ),
        ProfileMenuWidget(
          title: 'Logout',
          icon: LineAwesomeIcons.sign_out_alt_solid,
          textColor: Colors.red,
          onPress: () {},
        ),
      ],
    );
  }
}


// Những phần bạn cần xử lý phía Node.js hoặc logic Flutter khác:
// Quét thiết bị Bluetooth
//
// Kết nối thiết bị
//
// Lưu thông tin thiết bị vào server hoặc local
//
// Hiển thị dữ liệu glucose theo thời gian thực từ thiết bị