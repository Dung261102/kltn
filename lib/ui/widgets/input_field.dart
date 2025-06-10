// Tạo ô nhập liệu đẹp, tái sử dụng được với tiêu đề (reminder Page)
import 'package:flutter/material.dart';
// Import thư viện GetX để hỗ trợ quản lý trạng thái, theme,...
import 'package:get/get.dart';
// Import file theme định nghĩa sẵn style chữ (titleStyle, subTitleStyle)
import '../theme/theme.dart';

class MyInputField extends StatelessWidget {
  // Tiêu đề hiển thị phía trên ô nhập liệu
  final String title;
  // Gợi ý hiển thị trong ô nhập liệu
  final String hint;
  // Controller để lấy giá trị trong TextFormField
  final TextEditingController? controller;
  // Widget phụ (có thể là nút chọn ngày, giờ,...)
  final Widget? widget;

  // Constructor nhận vào các tham số và đánh dấu bắt buộc cho title và hint
  const MyInputField({
    super.key,
    required this.title,
    required this.hint,
    this.controller,
    this.widget,
  });

  // Phương thức build để tạo UI
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16), // Cách top 16 pixel
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
        children: [
          // Hiển thị tiêu đề (label) của ô nhập liệu
          Text(
            title,
            style: titleStyle, // Sử dụng style đã định nghĩa trong theme
          ),

          // Widget chứa ô nhập liệu và widget phụ bên cạnh
          Container(
            height: 52, // Chiều cao ô input
            padding: EdgeInsets.only(left: 14), // Padding bên trái
            margin: EdgeInsets.only(top: 8.0), // Cách tiêu đề phía trên 8px
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // Viền màu xám
                width: 1.0, // Độ dày viền
              ),
              borderRadius: BorderRadius.circular(12), // Bo góc viền
            ),
            child: Row(
              children: [
                // Widget mở rộng để chiếm phần lớn không gian
                Expanded(
                  child: TextFormField(
                    readOnly: widget == null ? false : true, // Nếu có widget thì không cho nhập
                    autofocus: false, // Không tự động focus
                    cursorColor:
                    Get.isDarkMode ? Colors.grey[100] : Colors.grey[700], // Màu con trỏ phụ thuộc theme
                    controller: controller, // Gắn controller để điều khiển dữ liệu nhập
                    style: subTitleStyle, // Style chữ cho nội dung nhập
                    decoration: InputDecoration(
                      hintText: hint, // Gợi ý nhập liệu
                      hintStyle: subTitleStyle, // Style chữ cho gợi ý

                      // Ẩn gạch dưới khi focus vào TextFormField
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: context.theme.scaffoldBackgroundColor, // Màu theo theme hiện tại
                          width: 0,
                        ),
                      ),
                      // Ẩn gạch dưới khi không focus
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: context.theme.scaffoldBackgroundColor,
                          width: 0,
                        ),
                      ),
                    ),
                  ),
                ),

                // Nếu có widget thì hiển thị widget, không thì trả về Container rỗng
                widget == null
                    ? Container()
                    : Container(child: widget),
              ],
            ),
          )
        ],
      ),
    );
  }
}
