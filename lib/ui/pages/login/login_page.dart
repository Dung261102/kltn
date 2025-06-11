import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucose_real_time/ui/pages/login/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // dùng để lưu dữ liệu cục bộ

import '../../../rest/rest_api.dart'; // chứa hàm gọi API đăng nhập
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/form_fields_widgets.dart'; // chứa widget tùy chỉnh cho input


// Màn hình đăng nhập - kế thừa StatefulWidget vì có dữ liệu thay đổi
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState(); // trả về state tương ứng
  }
}

// State chính của LoginPage
class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // dùng để validate form
  final TextEditingController _emailController = TextEditingController(); // controller cho ô email
  final TextEditingController _passwordController = TextEditingController(); // controller cho ô password

  late SharedPreferences _sharedPreferences; // biến dùng để lưu local dữ liệu sau khi đăng nhập

  @override
  Widget build(BuildContext context) {
    return Material( // dùng Material để hiển thị giao diện kiểu Material Design
      child: SingleChildScrollView( // giúp cuộn được khi bàn phím hiển thị
        child: Container(
          height: MediaQuery.of(context).size.height, // lấy chiều cao của màn hình
          width: MediaQuery.of(context).size.width,   // lấy chiều rộng của màn hình
          decoration: BoxDecoration(
            gradient: LinearGradient( // nền dạng gradient từ xám sang đen
              colors: [Colors.grey, Colors.black87],
              begin: const FractionalOffset(0.0, 1.0),
              end: const FractionalOffset(0.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.repeated,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 60), // khoảng cách phía trên logo
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/logo.png", // logo ứng dụng
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                ),
              ),
              SizedBox(height: 10),
              Form(
                key: _formKey, // gán form key để có thể validate sau này
                child: Column(
                  children: [
                    FormFields( // widget tùy chỉnh cho input email
                      controller: _emailController,
                      data: Icons.email,
                      txtHint: 'Email',
                      obsecure: false,
                    ),
                    FormFields( // widget tùy chỉnh cho input password
                      controller: _passwordController,
                      data: Icons.lock,
                      txtHint: 'Password',
                      obsecure: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot Password', // chỉ hiển thị, chưa xử lý chức năng quên mật khẩu
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton( // nút đăng nhập
                    onPressed: () {
                      // kiểm tra nếu cả 2 trường không rỗng thì gọi hàm doLogin, ngược lại hiện cảnh báo
                      _emailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty
                          ? doLogin(_emailController.text, _passwordController.text)
                          : Fluttertoast.showToast(
                        msg: 'All fields are required',
                        textColor: Colors.red,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // màu nền của nút
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white), // màu chữ nút
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              InkWell( // nhấn vào sẽ chuyển sang màn hình đăng ký
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don`t have an account', // hỏi người dùng nếu chưa có tài khoản
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Register', // chuyển sang trang đăng ký
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
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

  // Hàm xử lý đăng nhập
  doLogin(String email, String password) async {
    _sharedPreferences = await SharedPreferences.getInstance(); // khởi tạo SharedPreferences
    var res = await userLogin(email.trim(), password.trim()); // gọi API login từ rest_api.dart
    print(res.toString()); // in ra response để debug

    if (res['success']) { // nếu API trả về success = true
      String userEmail = res['user'][0]['email']; // lấy email người dùng từ response
      int userId = res['user'][0]['id']; // lấy id người dùng từ response
      _sharedPreferences.setInt('userid', userId); // lưu userId vào local
      _sharedPreferences.setString('usermail', userEmail); // lưu email vào local

      // chuyển sang trang chủ (homePage), thay thế luôn login page
      Route route = MaterialPageRoute(builder: (_) => MainPage());
      Navigator.pushReplacement(context, route);
    } else {
      // nếu đăng nhập không thành công, hiển thị thông báo lỗi
      Fluttertoast.showToast(
        msg: 'Email and password not valid ?',
        textColor: Colors.red,
      );
    }
  }
}
