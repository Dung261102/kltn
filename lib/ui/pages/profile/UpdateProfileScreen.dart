// Import các thư viện cần thiết
import 'package:flutter/material.dart'; // Thư viện Material UI của Flutter
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../theme/test/image_strings.dart';
import '../../theme/test/text_strings.dart'; // Thư viện GetX để quản lý trạng thái và điều hướng
// Một phần của GetX để lấy chức năng chính



// Định nghĩa một màn hình không có trạng thái để cập nhật thông tin cá nhân
class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold cung cấp cấu trúc cơ bản của một màn hình: app bar, body, floating action button, v.v.
    return Scaffold(
      // Thanh app bar trên cùng của màn hình
      appBar: AppBar(
        // Nút quay lại được thêm vào góc trái màn hình
        leading: IconButton(
          onPressed: () => Get.back(), // Sử dụng GetX để quay về màn hình trước đó
          icon: const Icon(LineAwesomeIcons.angle_left_solid), // Icon mũi tên quay lại
        ),
        // Tiêu đề ở giữa app bar
        title: Center(
          child: Text(
            tEditProflie, // Chuỗi văn bản hằng số, nội dung là "Edit Profile"
            style: Theme.of(context).textTheme.headlineMedium, // Áp dụng kiểu văn bản từ theme của ứng dụng
          ),
        ),
      ),

      // Body của trang, sử dụng SingleChildScrollView để hỗ trợ cuộn màn hình
      body: SingleChildScrollView(
        // Container chứa nội dung của body
        child: Container(
          padding: const EdgeInsets.all(25), // Padding xung quanh
          child: Column(
            children: [
              // Phần hiển thị ảnh đại diện (avatar)
              Stack(
                children: [
                  // Ảnh đại diện được bao bởi hình tròn
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100), // Tạo hình tròn cho ảnh
                      child: Image(image: AssetImage(tProfileImage)), // Ảnh đại diện từ asset
                    ),
                  ),
                  // Nút thay đổi ảnh được đặt ở góc phải dưới của ảnh đại diện
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100), // Tạo hình tròn cho nút
                        color: Colors.white, // Nền trắng cho nút
                      ),
                      child: const Icon(
                        LineAwesomeIcons.camera_solid, // Icon máy ảnh
                        size: 18, // Kích thước icon
                        color: Colors.grey, // Màu xám cho icon
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50), // Khoảng cách giữa avatar và form

              // Form để nhập các thông tin người dùng
              Form(
                child: Column(
                  children: [
                    // Ô nhập tên đầy đủ
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Full Name"), // Nhãn hiển thị "Full Name"
                        prefixIcon: Icon(LineAwesomeIcons.user), // Icon người dùng
                      ),
                    ),
                    const SizedBox(height: 20), // Khoảng cách giữa các ô nhập

                    // Ô nhập email
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("E-Mail"), // Nhãn hiển thị "E-Mail"
                        prefixIcon: Icon(LineAwesomeIcons.envelope), // Icon phong bì
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ô nhập số điện thoại
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Phone Number"), // Nhãn hiển thị "Phone Number"
                        prefixIcon: Icon(LineAwesomeIcons.phone_solid), // Icon điện thoại
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ô nhập mật khẩu
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Password"), // Nhãn hiển thị "Password"
                        prefixIcon: Icon(LineAwesomeIcons.fingerprint_solid), // Icon dấu vân tay
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nút "Edit Profile" để cập nhật thông tin
                    SizedBox(
                      width: double.infinity, // Kích thước nút bằng với chiều rộng màn hình
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const UpdateProfileScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Nền đen
                          side: BorderSide.none, // Không có viền
                          shape: StadiumBorder(), // Nút có hình dạng tròn như sân vận động
                        ), // Khi nhấn sẽ chuyển đến màn hình cập nhật profile
                        child: Text(
                          tEditProflie, // Nội dung nút là "Edit Profile"
                          style: TextStyle(color: Colors.white), // Màu chữ trắng
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dòng chữ hiển thị thời gian tham gia và nút xóa tài khoản
                    Row(
                      children: [
                        const Text.rich(
                          TextSpan(
                            text: tJoined, // Chuỗi văn bản "Joined"
                            style: TextStyle(fontSize: 12), // Cỡ chữ nhỏ
                            children: [
                              TextSpan(text: tJoinedAt, style: TextStyle(fontSize: 12)) // Thời gian tham gia
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {}, // Nút chưa có chức năng
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), // Nút màu đỏ
                          child: const Text(tDelete), // Nút "Delete"
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
