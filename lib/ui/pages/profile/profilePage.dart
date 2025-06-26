import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/ui/pages/profile/profile_menu.dart';
import 'package:glucose_real_time/services/notification_services.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:glucose_real_time/ui/widgets/common_appbar.dart';
import 'package:glucose_real_time/ui/widgets/button.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:glucose_real_time/ui/pages/profile/viewProfile.dart';

import 'UpdateProfileScreen.dart';
import 'ble.dart';
import 'package:glucose_real_time/controllers/ble_controller.dart';
import 'package:glucose_real_time/services/glucose_service.dart';
import 'dart:async';

import 'package:get_storage/get_storage.dart'; // thư viện lưu trữ biến cục bộ
import 'package:glucose_real_time/db/db_helper.dart';
import 'package:glucose_real_time/services/theme_service.dart';
import 'package:glucose_real_time/ui/pages/login/login_page.dart';
import 'package:glucose_real_time/ui/theme/test/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucose_real_time/controllers/user_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final NotifyHelper notifyHelper = NotifyHelper();
  late SharedPreferences _sharedPreferences;
  final BleController bleController = Get.put(BleController());
  final GlucoseService _glucoseService = GlucoseService();
  final UserController userController = Get.put(UserController());

  // Tên người dùng hiện tại
  String userName = "User"; // Default name
  String avatarPath = "assets/images/profile/avatar.jpg";
  Uint8List? avatarBytes; // Thêm biến này để lưu avatar base64 (web)

  // Thông tin cơ thể người dùng
  double height = 0.0;  // Chiều cao mặc định (cm)
  double weight = 0.0;   // Cân nặng mặc định (kg)
  int age = 0;          // Tuổi mặc định

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAvatar();
  }

  Future<void> _loadUserData() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userName = _sharedPreferences.getString('username') ?? "User";
      height = _sharedPreferences.getDouble('height') ?? 0.0;
      weight = _sharedPreferences.getDouble('weight') ?? 0.0;
      age = _sharedPreferences.getInt('age') ?? 0;
    });
    userController.setUsername(userName);
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('avatar');
    final base64Str = prefs.getString('avatar_base64');
    if (base64Str != null && base64Str.isNotEmpty) {
      setState(() {
        avatarBytes = base64Decode(base64Str);
        avatarPath = "";
      });
      userController.setAvatarBytes(avatarBytes);
    } else if (savedAvatar != null && savedAvatar.isNotEmpty) {
      setState(() {
        avatarPath = savedAvatar;
        avatarBytes = null;
      });
      userController.setAvatarPath(avatarPath);
    } else {
      setState(() {
        avatarPath = "assets/images/profile/avatar.jpg";
        avatarBytes = null;
      });
      userController.setAvatarPath(avatarPath);
    }
  }

  // Hàm cập nhật chiều cao
  void _updateHeight() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Height'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter height in cm',
            suffixText: 'cm',
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                height = double.parse(value);
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // Hàm cập nhật cân nặng
  void _updateWeight() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Weight'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter weight in kg',
            suffixText: 'kg',
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                weight = double.parse(value);
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // Hàm cập nhật tuổi
  void _updateAge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Age'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter age',
            suffixText: 'years',
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                age = int.parse(value);
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // Hàm gọi khi người dùng xoá thiết bị - xử lý sau
  void _onClearDevicePressed() {
    // TODO: Gắn kết logic xoá thiết bị đã lưu
  }

  // Hàm kiểm tra và xoá tài khoản đã lưu ở local
  Future<void> checkAndDeleteLocalAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid');
    final userMail = prefs.getString('usermail');
    if (userId != null || userMail != null) {
      // Nếu có tài khoản, tiến hành xoá
      await prefs.remove('userid');
      await prefs.remove('usermail');
      await prefs.remove('username');
      await prefs.remove('isLoggedIn');
      await prefs.remove('height');
      await prefs.remove('weight');
      await prefs.remove('age');
      await prefs.remove('avatar');
      await prefs.remove('avatar_base64');
      Fluttertoast.showToast(
        msg: 'Đã xoá tài khoản local thành công!',
        textColor: Colors.green,
      );
      // Chuyển về màn hình đăng nhập
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      Fluttertoast.showToast(
        msg: 'Không có tài khoản local nào để xoá!',
        textColor: Colors.orange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
        title: 'Profile',
      ),
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
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
          child: Column(
            children: [
              _buildProfileHeader(),             // Bấm avatar sẽ điều hướng đến chỉnh sửa
              const SizedBox(height: 15),
              _buildDeviceInfo(),                // UI thêm thiết bị và thông tin thiết bị
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              _buildMenuOptions(),               // Danh sách chức năng khác
            ],
          ),
        ),
      ),
    );
  }

  // UI hiển thị thông tin thiết bị và các nút tương tác
  Widget _buildDeviceInfo() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Get.to(() => BleView());
          },
          child: const Text("Add Device"),
        ),
        Obx(() {
          final device = bleController.connectedDevice.value;
          if (device == null) return SizedBox.shrink();
          return Column(
            children: [
              const SizedBox(height: 10),
              Text("Connected device:", style: Theme.of(context).textTheme.bodyMedium),
              Text("${device.name} (${device.id.id})", style: const TextStyle(color: Colors.blueAccent)),
              TextButton(
                onPressed: () async {
                  await bleController.disconnectDevice();
                },
                child: const Text("Disconnect Device", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        }),
      ],
    );
  }

  // Avatar + tên người dùng, có thể bấm để chỉnh sửa profile
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryClr, width: 3),
                ),
                child: ClipOval(
                  child: avatarBytes != null
                      ? Image.memory(avatarBytes!, fit: BoxFit.cover, width: 114, height: 114)
                      : (avatarPath.startsWith('/')
                          ? Image.file(File(avatarPath), fit: BoxFit.cover, width: 114, height: 114)
                          : Image.asset(avatarPath, fit: BoxFit.cover, width: 114, height: 114)),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final result = await Get.to(() => const UpdateProfileScreen());
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      userName = result['name'] ?? userName;
                      height = result['height'] ?? height;
                      weight = result['weight'] ?? weight;
                      age = result['age'] ?? age;
                      if (result['avatar_base64'] != null && result['avatar_base64'].toString().isNotEmpty) {
                        avatarBytes = base64Decode(result['avatar_base64']);
                        avatarPath = "";
                        userController.setAvatarBytes(avatarBytes);
                      } else if (result['avatar'] != null && result['avatar'].toString().isNotEmpty) {
                        avatarPath = result['avatar'];
                        avatarBytes = null;
                        userController.setAvatarPath(avatarPath);
                      }
                    });
                    if (result['avatar_base64'] != null && result['avatar_base64'].toString().isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('avatar_base64', result['avatar_base64']);
                    } else if (result['avatar'] != null && result['avatar'].toString().isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('avatar', avatarPath);
                      await prefs.remove('avatar_base64');
                    }
                    userController.setUsername(userName);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                    border: Border.all(color: primaryClr, width: 1.5),
                  ),
                  child: Icon(
                    LineAwesomeIcons.pen_fancy_solid,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          userName,
          style: headingStyle.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MyButton(
              label: "${height} cm\nHeight",
              onTap: () {},
              color: Colors.white,
              valueStyle: titleStyle.copyWith(color: primaryClr, fontWeight: FontWeight.bold),
              labelStyle: subTitleStyle.copyWith(color: Colors.black54),
            ),
            MyButton(
              label: "${weight} kg\nWeight",
              onTap: () {},
              color: Colors.white,
              valueStyle: titleStyle.copyWith(color: primaryClr, fontWeight: FontWeight.bold),
              labelStyle: subTitleStyle.copyWith(color: Colors.black54),
            ),
            MyButton(
              label: "${age} years\nAge",
              onTap: () {},
              color: Colors.white,
              valueStyle: titleStyle.copyWith(color: primaryClr, fontWeight: FontWeight.bold),
              labelStyle: subTitleStyle.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ],
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
          textColor: Colors.black87,
        ),
        ProfileMenuWidget(
          title: 'Profile',
          icon: LineAwesomeIcons.user,
          onPress: () {
            Get.to(() => ViewProfileScreen());
          },
          textColor: Colors.black87,
        ),
        ProfileMenuWidget(
          title: 'Privacy Policy',
          icon: LineAwesomeIcons.key_solid,
          onPress: () {},
          textColor: Colors.black87,
        ),
        const Divider(color: Colors.black),
        const SizedBox(height: 10),
        ProfileMenuWidget(
          title: 'Help',
          icon: LineAwesomeIcons.question_circle,
          onPress: () {},
          textColor: Colors.black87,
        ),

  //hàm xoá 
        // ProfileMenuWidget(
        //   title: 'Xoá tài khoản local',
        //   icon: LineAwesomeIcons.trash_alt_solid,
        //   textColor: Colors.red,
        //   onPress: () async {
        //     bool? confirm = await showDialog<bool>(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return AlertDialog(
        //           title: Text('Xoá tài khoản local'),
        //           content: Text('Bạn có chắc chắn muốn xoá tài khoản local khỏi thiết bị?'),
        //           actions: [
        //             TextButton(
        //               onPressed: () => Navigator.of(context).pop(false),
        //               child: Text('Huỷ'),
        //             ),
        //             TextButton(
        //               onPressed: () => Navigator.of(context).pop(true),
        //               child: Text('Xoá'),
        //               style: TextButton.styleFrom(foregroundColor: Colors.red),
        //             ),
        //           ],
        //         );
        //       },
        //     );
        //     if (confirm == true) {
        //       await checkAndDeleteLocalAccount();
        //     }
        //   },
        // ),

        //hàm xoá 

        ProfileMenuWidget(
          title: 'Logout',
          icon: LineAwesomeIcons.sign_out_alt_solid,
          textColor: Colors.red,
          onPress: () async {
            bool? shouldLogout = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Logout'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                );
              },
            );

            if (shouldLogout == true) {
              await _performLogout();
            }
          },
        ),
      ],
    );
  }

  Future<void> _performLogout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Chỉ xóa thông tin đăng nhập
      await prefs.remove('userid');
      await prefs.remove('usermail');
      await prefs.remove('username');
      await prefs.remove('isLoggedIn');
      
      // KHÔNG xóa dữ liệu profile và glucose để giữ lại khi login lại
      // await prefs.remove('height');
      // await prefs.remove('weight');
      // await prefs.remove('age');
      
      // Hiển thị thông báo
      Fluttertoast.showToast(
        msg: 'Logged out successfully. Your data will be preserved.',
        textColor: Colors.green,
      );
      
      // Chuyển về trang login
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // Xóa tất cả route trong stack
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error during logout: $e',
        textColor: Colors.red,
      );
    }
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