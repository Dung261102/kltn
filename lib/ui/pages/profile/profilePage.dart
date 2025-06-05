import 'package:flutter/material.dart'; // Thư viện Flutter cơ bản để xây dựng giao diện người dùng
import 'package:get/get.dart'; // Thư viện GetX để quản lý điều hướng và trạng thái
import 'package:glucose_real_time/ui/pages/profile/profile_menu.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
// Import cốt lõi của GetX (có thể không cần vì đã có gói `get.dart`)


import '../../../services/notification_services.dart';
import '../../theme/test/image_strings.dart';
import '../../theme/test/text_strings.dart';
import '../../widgets/common_appbar.dart';
import 'UpdateProfileScreen.dart'; // Import màn hình cập nhật hồ sơ

// Tạo một class `ProfilePage` kế thừa từ `StatelessWidget` để xây dựng trang hồ sơ (Profile)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    // Lấy instance NotifyHelper singleton
    final NotifyHelper notifyHelper = NotifyHelper();

    // // Lấy giá trị độ sáng của thiết bị (chế độ tối hoặc sáng)
    // var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold( // Scaffold cung cấp cấu trúc giao diện chính cho màn hình

      // appBar: AppBar( // Thanh AppBar ở đầu trang
      //   leading: IconButton( // Nút quay lại
      //     onPressed: () {}, // Hành động khi nhấn nút quay lại, hiện tại chưa có logic
      //     icon: const Icon(LineAwesomeIcons.angle_left_solid), // Biểu tượng nút quay lại
      //   ),
      //   title: Center( // Tiêu đề của AppBar nằm ở giữa
      //     child: Text(
      //       tProflie, // Chuỗi văn bản cho tiêu đề từ `text_strings.dart`
      //       style: Theme.of(context).textTheme.headlineMedium, // Áp dụng kiểu chữ từ chủ đề của ứng dụng
      //     ),
      //   ),
      //   actions: [
      //     IconButton( // Nút để chuyển đổi giữa chế độ tối và sáng
      //       onPressed: () {}, // Hành động khi nhấn vào nút (chưa có logic)
      //       icon: Icon(
      //         isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon_solid, // Biểu tượng thay đổi tùy theo chế độ
      //       ),
      //     ),
      //   ],
      // ),

      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
        // thêm code để chỉnh sửa app bar tại đây
      ),

      // Nội dung chính của màn hình được cuộn lại với SingleChildScrollView
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25), // Thêm khoảng đệm 25px xung quanh nội dung
          child: Column( // Sử dụng cột để sắp xếp các widget theo chiều dọc
            children: [
              Stack( // Widget Stack để xếp chồng các phần tử lên nhau
                children: [
                  SizedBox( // Kích thước của hình ảnh avatar
                    width: 120,
                    height: 120,
                    child: ClipRRect( // Làm tròn các góc của ảnh để tạo thành ảnh tròn
                      borderRadius: BorderRadius.circular(100), // Đặt bán kính bo góc là 100 để thành hình tròn
                      child: Image(image: AssetImage(tProfileImage)), // Hiển thị hình ảnh từ tài nguyên
                    ),
                  ),
                  // Vị trí của biểu tượng sửa hồ sơ (nút nhỏ bên cạnh avatar)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container( // Hộp chứa biểu tượng sửa
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration( // Kiểu dáng hộp chứa
                          borderRadius: BorderRadius.circular(100), // Làm tròn thành hình tròn
                          color: Colors.white, // Màu nền là màu trắng
                        ),
                        child: const Icon( // Biểu tượng bên trong
                            LineAwesomeIcons.angle_right_solid, // Biểu tượng mũi tên phải
                            size: 18,
                            color: Colors.grey)),
                  )
                ],
              ),
              const SizedBox(height: 10), // Khoảng cách giữa ảnh avatar và văn bản

              // Văn bản tiêu đề hồ sơ
              Text(
                tProflieheading, // Chuỗi văn bản từ `text_strings.dart`
                style: Theme.of(context).textTheme.headlineMedium, // Áp dụng kiểu chữ
              ),
              // Văn bản phụ dưới tiêu đề
              Text(
                tProflieSubHeading, // Chuỗi văn bản phụ
                style: Theme.of(context).textTheme.headlineMedium, // Áp dụng kiểu chữ
              ),
              const SizedBox(height: 20), // Khoảng cách giữa văn bản và nút chỉnh sửa

              // Nút cập nhật hồ sơ
              SizedBox(
                width: 200, // Đặt chiều rộng của nút là 200
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const UpdateProfileScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Màu nền đen
                    side: BorderSide.none, // Không có viền
                    shape: StadiumBorder(), // Hình dạng của nút là bầu dục
                  ), // Điều hướng đến trang cập nhật hồ sơ sử dụng GetX
                  child: Text(
                    tEditProflie, // Văn bản hiển thị trên nút từ `text_strings.dart`
                    style: TextStyle(color: Colors.white), // Màu chữ trắng
                  ),
                ),
              ),
              const SizedBox(height: 30), // Khoảng cách giữa nút và các thành phần khác
              const Divider(), // Đường kẻ phân cách
              const SizedBox(height: 10), // Khoảng cách trước menu

              // Menu hồ sơ với các tùy chọn
              ProfileMenuWidget(
                title: 'Settings', // Tiêu đề menu là 'Settings'
                icon: LineAwesomeIcons.cog_solid, // Biểu tượng bánh răng
                onPress: () {}, // Hành động khi nhấn (chưa có logic)
              ),
              ProfileMenuWidget(
                title: 'Billing Details', // Tiêu đề menu là 'Billing Details'
                icon: LineAwesomeIcons.wallet_solid, // Biểu tượng ví
                onPress: () {}, // Hành động khi nhấn (chưa có logic)
              ),
              ProfileMenuWidget(
                title: 'User Management', // Tiêu đề menu là 'User Management'
                icon: LineAwesomeIcons.user_check_solid, // Biểu tượng người dùng
                onPress: () {}, // Hành động khi nhấn (chưa có logic)
              ),
              const Divider(color: Colors.red), // Đường kẻ đỏ ngăn cách các mục menu khác
              const SizedBox(height: 10), // Khoảng cách trước mục menu tiếp theo
              ProfileMenuWidget(
                title: 'Information', // Tiêu đề menu là 'Information'
                icon: LineAwesomeIcons.info_solid, // Biểu tượng thông tin
                onPress: () {}, // Hành động khi nhấn (chưa có logic)
              ),
              ProfileMenuWidget(
                title: 'Logout', // Tiêu đề menu là 'Logout'
                icon: LineAwesomeIcons.sign_out_alt_solid, // Biểu tượng đăng xuất
                textColor: Colors.red, // Màu chữ đỏ
                onPress: () {}, // Hành động khi nhấn (chưa có logic)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
