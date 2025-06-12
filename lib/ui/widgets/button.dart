import 'package:flutter/material.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';  // Import theme

class MyButton extends StatelessWidget {
  final String label;                        // Nhãn nút
  final Function()? onTap;                  // Hàm khi nhấn nút
  final Color? color;                       // Màu nền có thể tùy chỉnh
  final double width;                       // Chiều rộng nút
  final double height;                      // Chiều cao nút
  final Color? borderColor;                 // Màu viền
  final double borderRadius;                // Độ bo góc
  final TextStyle? labelStyle;              // Style cho label
  final TextStyle? valueStyle;              // Style cho giá trị

  const MyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,                              // Có thể null => sẽ dùng màu mặc định
    this.width = 100,                        // Giá trị mặc định
    this.height = 60,                        // Giá trị mặc định
    this.borderColor,
    this.borderRadius = 10,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,                        // Gán chiều rộng
        height: height,                      // Gán chiều cao
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: color ?? Colors.white,
          border: Border.all(
            color: borderColor ?? Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (valueStyle != null)
              Text(
                label.split('\n')[0],
                style: valueStyle,
              ),
            Text(
              label.split('\n').length > 1 ? label.split('\n')[1] : label,
              style: labelStyle ?? titleStyle.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

//cách tái sử dụng
// MyButton(
// label: "+ Add Task",
// onTap: () {
// print("Tapped Add Task");
// },
// color: Colors.green,        // Tùy chỉnh màu sắc
// width: 140,                 // Tùy chỉnh chiều rộng
// height: 50,                 // Tùy chỉnh chiều cao
// ),

