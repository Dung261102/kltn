import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:typed_data';

const Color profileBlue = Color(0xFF4e5ae8); // Xanh dương dịu cho profile

class UpdateProfileController extends GetxController {
  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();
  RxString avatarPath = ''.obs;
  Rx<Uint8List?> avatarBytes = Rx<Uint8List?>(null);

  @override
  void onClose() {
    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.onClose();
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        avatarBytes.value = bytes;
        avatarPath.value = '';
      } else {
        avatarPath.value = picked.path;
      }
    }
  }

  void saveChanges() async {
    final updatedName = nameController.text.trim();
    final heightText = heightController.text.trim();
    final weightText = weightController.text.trim();
    final ageText = ageController.text.trim();
    final Map<String, dynamic> result = {};
    final prefs = await SharedPreferences.getInstance();
    if (updatedName.isNotEmpty) {
      result['name'] = updatedName;
      await prefs.setString('username', updatedName);
    }
    if (heightText.isNotEmpty) {
      final height = double.tryParse(heightText);
      if (height == null || height <= 0) {
        Get.snackbar("Error", "Please enter a valid height");
        return;
      }
      result['height'] = height;
      await prefs.setDouble('height', height);
    }
    if (weightText.isNotEmpty) {
      final weight = double.tryParse(weightText);
      if (weight == null || weight <= 0) {
        Get.snackbar("Error", "Please enter a valid weight");
        return;
      }
      result['weight'] = weight;
      await prefs.setDouble('weight', weight);
    }
    if (ageText.isNotEmpty) {
      final age = int.tryParse(ageText);
      if (age == null || age <= 0) {
        Get.snackbar("Error", "Please enter a valid age");
        return;
      }
      result['age'] = age;
      await prefs.setInt('age', age);
    }
    if (!kIsWeb && avatarPath.value.isNotEmpty) {
      result['avatar'] = avatarPath.value;
      await prefs.setString('avatar', avatarPath.value);
    }
    if (kIsWeb && avatarBytes.value != null) {
      result['avatar_base64'] = base64Encode(avatarBytes.value!);
      await prefs.setString('avatar_base64', result['avatar_base64']);
    }
    if (result.isEmpty) {
      Get.snackbar("Notice", "No changes were made");
      return;
    }
    Get.back(result: result);
  }
}

/// Màn hình cập nhật hồ sơ người dùng
class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(LineAwesomeIcons.angle_left_solid),
      ),
      centerTitle: true,
      title: Text(
          'Edit Profile',
          style: headingStyle
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateProfileController());
    // Lấy avatar từ SharedPreferences nếu có, chỉ khi controller chưa có avatar tạm thời
    if (controller.avatarPath.value.isEmpty && controller.avatarBytes.value == null) {
      SharedPreferences.getInstance().then((prefs) {
        final savedAvatar = prefs.getString('avatar');
        if (savedAvatar != null && savedAvatar.isNotEmpty) {
          controller.avatarPath.value = savedAvatar;
        }
      });
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2C6FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _buildAvatar(controller),
              const SizedBox(height: 50),
              _buildProfileForm(controller),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị ảnh đại diện và nút thay đổi ảnh
  Widget _buildAvatar(UpdateProfileController controller) {
    return Stack(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: profileBlue, width: 3),
            ),
            child: ClipOval(
              child: kIsWeb
                  ? _buildWebAvatar(controller)
                  : _buildMobileAvatar(controller),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.pickAvatar,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: profileBlue, width: 1.5),
              ),
              child: Icon(
                LineAwesomeIcons.camera_solid,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebAvatar(UpdateProfileController controller) {
    // Nếu đã chọn ảnh mới, dùng Obx để update
    return Obx(() {
      if (controller.avatarBytes.value != null) {
        return Image.memory(controller.avatarBytes.value!, fit: BoxFit.cover);
      }
      // Nếu reload lại, dùng FutureBuilder lấy từ SharedPreferences
      return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final prefs = snapshot.data as SharedPreferences;
            final base64Str = prefs.getString('avatar_base64');
            if (base64Str != null && base64Str.isNotEmpty) {
              final bytes = base64Decode(base64Str);
              // Không update Rx ở đây để tránh lỗi Obx, chỉ trả về Image.memory
              return Image.memory(bytes, fit: BoxFit.cover);
            }
          }
          return Image.asset('assets/images/profile/avatar.jpg');
        },
      );
    });
  }

  Widget _buildMobileAvatar(UpdateProfileController controller) {
    return Obx(() {
      if (controller.avatarPath.value.isNotEmpty) {
        return controller.avatarPath.value.startsWith('/')
            ? Image.file(File(controller.avatarPath.value), fit: BoxFit.cover)
            : Image.asset(controller.avatarPath.value);
      }
      return Image.asset('assets/images/profile/avatar.jpg');
    });
  }

  /// Form nhập thông tin người dùng
  Widget _buildProfileForm(UpdateProfileController controller) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'User Name',
              labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              prefixIcon: Icon(LineAwesomeIcons.user, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              prefixIcon: Icon(LineAwesomeIcons.arrow_alt_circle_up, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              prefixIcon: Icon(LineAwesomeIcons.chart_bar, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              prefixIcon: Icon(LineAwesomeIcons.calendar, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
