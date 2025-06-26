//TaskTile là một widget hiển thị từng task trong danh sách công việc (reminder Page)

// Nhập các gói thư viện cần thiết
import 'package:flutter/cupertino.dart'; // Thư viện giao diện giống iOS
import 'package:flutter/material.dart'; // Thư viện giao diện chung của Flutter
import 'package:google_fonts/google_fonts.dart'; // Thư viện hỗ trợ font chữ từ Google Fonts

// Nhập model Task và file theme
import '../../models/task.dart'; // Import lớp Task (định nghĩa các thuộc tính công việc)
import '../theme/theme.dart';    // Import các màu sắc định nghĩa trong theme

// Định nghĩa một widget hiển thị công việc (task) trên giao diện
class TaskTile extends StatelessWidget {
  final Task? task; // Biến task có thể null, đại diện cho một công việc
  TaskTile(this.task); // Constructor nhận task truyền vào

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBGClr(task?.color ?? 0);
    // Nếu là một trong các màu pastel (mint, cam đào nhạt, tím lavender), text sẽ là đen/xám đậm
    final bool isLightBG = bgColor.value == bluishClr.value || bgColor.value == yellowClr.value || bgColor.value == pinkClr.value;
    final Color mainTextColor = isLightBG ? Colors.black87 : Colors.white;
    final Color subTextColor = isLightBG ? Colors.black54 : Colors.white;
    final List<Shadow> textShadows = [
      Shadow(color: Colors.black26, blurRadius: isLightBG ? 1 : 2, offset: Offset(1,1)),
      if (isLightBG) Shadow(color: Colors.white, blurRadius: 2, offset: Offset(0,0)),
    ];

    return Container(
      // Padding lề trái phải
      padding: EdgeInsets.symmetric(horizontal: 20),
      // Đặt chiều rộng = chiều rộng của màn hình
      width: MediaQuery.of(context).size.width,
      // Khoảng cách bên dưới giữa các task
      margin: EdgeInsets.only(bottom: 12),
      child: Container(
        // Padding bên trong task
        padding: EdgeInsets.all(16),
        // Tạo khung với bo góc và màu nền dựa trên màu task
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color:  bgColor, // Lấy màu từ task.color, nếu null thì dùng 0
        ),

        // Nội dung task được bố trí theo hàng ngang
        child: Row(
          children: [
            // Phần hiển thị nội dung bên trái
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
                children: [
                  // Tiêu đề công việc
                  Text(
                    task?.title ?? "",
                    style: titleStyle.copyWith(
                      color: mainTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      shadows: textShadows,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Hiển thị thời gian bắt đầu - kết thúc
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.deepOrangeAccent,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "${task!.startTime} - ${task!.endTime}",
                        style: subTitleStyle.copyWith(
                          color: isLightBG ? Colors.teal[800] : Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1,1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Ghi chú (note) cho công việc
                  Text(
                    task!.note ?? "", // Nếu note null thì hiển thị chuỗi rỗng
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: isLightBG ? Colors.deepPurpleAccent : pinkClr,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1,1)),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),

            // Vạch ngăn cách giữa nội dung và trạng thái
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 0.5,
              color: Colors.grey[200]!.withOpacity(0.7), // Vạch mờ
            ),

            // Hiển thị trạng thái công việc (Completed hoặc TODO)
            RotatedBox(
              quarterTurns: 3, // Xoay chữ theo chiều dọc
              child: Text(
                task!.isCompleted == 1 ? "COMPLETED" : "TODO", // Kiểm tra trạng thái
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: task!.isCompleted == 1
                        ? (isLightBG ? Colors.green[700] : Colors.lightGreenAccent)
                        : (isLightBG ? Colors.orange[800] : Colors.amberAccent),
                    shadows: textShadows,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm lấy màu nền theo số nguyên trong task.color
  _getBGClr(int no) {
    switch(no) {
      case 0:
        return bluishClr; // Màu xanh dương
      case 1:
        return pinkClr; // Màu hồng
      case 2:
        return yellowClr; // Màu vàng
      default:
        return bluishClr; // Mặc định màu xanh dương
    }
  }
}
