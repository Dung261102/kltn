import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UpdateProfileController extends GetxController {
  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.onClose();
  }

  void saveChanges() {
    // Get current values
    final updatedName = nameController.text.trim();
    final heightText = heightController.text.trim();
    final weightText = weightController.text.trim();
    final ageText = ageController.text.trim();

    // Create result map with only changed values
    final Map<String, dynamic> result = {};

    // Only add name if it's not empty
    if (updatedName.isNotEmpty) {
      result['name'] = updatedName;
    }

    // Only validate and add height if it's been changed
    if (heightText.isNotEmpty) {
      final height = double.tryParse(heightText);
      if (height == null || height <= 0) {
        Get.snackbar("Error", "Please enter a valid height");
        return;
      }
      result['height'] = height;
    }

    // Only validate and add weight if it's been changed
    if (weightText.isNotEmpty) {
      final weight = double.tryParse(weightText);
      if (weight == null || weight <= 0) {
        Get.snackbar("Error", "Please enter a valid weight");
        return;
      }
      result['weight'] = weight;
    }

    // Only validate and add age if it's been changed
    if (ageText.isNotEmpty) {
      final age = int.tryParse(ageText);
      if (age == null || age <= 0) {
        Get.snackbar("Error", "Please enter a valid age");
        return;
      }
      result['age'] = age;
    }

    // If no changes were made, show a message
    if (result.isEmpty) {
      Get.snackbar("Notice", "No changes were made");
      return;
    }

    // Return the changes
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
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 50),
            _buildProfileForm(controller),
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
        SizedBox(
          width: 120,
          height: 120,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            child: Image.asset('assets/images/profile/avatar.jpg'),
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
  Widget _buildProfileForm(UpdateProfileController controller) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(LineAwesomeIcons.user),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              prefixIcon: Icon(LineAwesomeIcons.arrow_alt_circle_up),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              prefixIcon: Icon(LineAwesomeIcons.chart_bar),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              prefixIcon: Icon(LineAwesomeIcons.calendar),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
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
