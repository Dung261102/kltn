import 'package:flutter/material.dart';

import '../../theme/test/badge.dart';
import '../../theme/test/image_strings.dart';

class HomeAppBar extends StatelessWidget {
  final String? name; // Cho phép giá trị name có thể null
  final String? avatarUrl;
  final int notificationCount; // Biến này vẫn được truyền từ ngoài vào và không thay đổi trong widget này

  // HomeAppBar là thanh AppBar của HomePage
  const HomeAppBar({super.key, 
    this.name,
    this.avatarUrl,
    required this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu tên là null hoặc rỗng, sử dụng tên mặc định là "Dung"
    String displayName = (name == null || name!.isEmpty) ? 'Dung' : name!;

    //container bao trùm bên ngoài
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Row( // Row có 4 thành phần
        children: [

          //Thành phần 1
          // CircleAvatar sẽ hiển thị avatar từ URL hoặc hình ảnh mặc định
          CircleAvatar(
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : AssetImage("assets/images/profile/avatar.jpg") as ImageProvider,
            backgroundColor: Colors.blue,
            radius: 30,
          ),

          //khoảng cách giữa thành phần 1 và 2
          Padding(
            padding: EdgeInsets.only(left: 20),

            // Thành phần 2, có 2 dòng nên dùng Column
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chào mừng người dùng trở lại với tên của họ hoặc tên mặc định
                Text(
                  "Hi, WelcomeBack",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  displayName, // Hiển thị tên người dùng hoặc "Dung" nếu không có tên
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Spacer(), //khoảng cách tự động, đẩy 2 thành phần còn lại sang bên phải

          // Thành phần 3 - xài hàm có sẵn
          // Nút thông báo với Badge hiển thị số lượng thông báo
          IconButtonWithBadge(
            icon: Icons.notifications,
            // badgeContent sẽ hiển thị số lượng thông báo được truyền từ ngoài vào
            badgeContent: notificationCount > 0 ? notificationCount.toString() : "3",
            onPressed: () {
              // Khi người dùng nhấn vào biểu tượng thông báo, cần quản lý việc tăng số lượng thông báo từ bên ngoài widget này
              print('Notification icon clicked');
            },
          ),

          SizedBox(width: 10), //khoảng cách giữa 2 thành phần

          // Thành phần 4 -  xài hàm có sẵn
          // Nút cài đặt với biểu tượng
          CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 24,
            child: IconButton(
              icon: Icon(Icons.settings),
              iconSize: 32,
              color: Colors.white,
              onPressed: () => print('Settings icon clicked'),
            ),
          ),
        ],
      ),
    );
  }
}
