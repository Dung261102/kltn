import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

/// Màn hình cập nhật hồ sơ người dùng
class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller cho các ô nhập liệu
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LineAwesomeIcons.angle_left_solid),
        ),
        title: Center(
          child: Text(
            'Edit Profile',
            style: headingStyle
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 50),
            _buildProfileForm(nameController),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Widget hiển thị ảnh đại diện và nút thay đổi ảnh
  Widget _buildAvatar() {
    return Stack(
      children: [
        const SizedBox(
          width: 120,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            child: Image(
              image: AssetImage('assets/images/profile/avatar.jpg'),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LineAwesomeIcons.camera_solid,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  /// Form nhập thông tin người dùng
  Widget _buildProfileForm(TextEditingController nameController) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(LineAwesomeIcons.user),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'E-Mail',
              prefixIcon: Icon(LineAwesomeIcons.envelope),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(LineAwesomeIcons.phone_solid),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(LineAwesomeIcons.fingerprint_solid),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final updatedName = nameController.text.trim();
                if (updatedName.isNotEmpty) {
                  Get.back(result: updatedName); // Trả tên về ProfilePage
                } else {
                  Get.snackbar("Lỗi", "Vui lòng nhập tên hợp lệ");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
