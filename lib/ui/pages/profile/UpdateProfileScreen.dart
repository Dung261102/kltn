import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

/// Màn hình cập nhật hồ sơ người dùng
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  // Controller cho các ô nhập liệu
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _buildProfileForm(),
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
  Widget _buildProfileForm() {
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
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              prefixIcon: Icon(LineAwesomeIcons.arrow_alt_circle_up),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              prefixIcon: Icon(LineAwesomeIcons.chart_bar),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: ageController,
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
              onPressed: () {
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
