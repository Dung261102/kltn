import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucose_real_time/ui/pages/login/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // dùng để lưu dữ liệu cục bộ
import 'package:glucose_real_time/ui/theme/theme.dart';  // Import theme

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
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            width: 380,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Image.asset(
                  "assets/images/logo.png",
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 18),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.blue[300]),
                          hintText: 'Email',
                          filled: true,
                          fillColor: Color(0xFFF6F7FB),
                          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue, width: 1.5),
                          ),
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 18),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.blue[300]),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Color(0xFFF6F7FB),
                          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue, width: 1.5),
                          ),
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _emailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty
                          ? doLogin(_emailController.text, _passwordController.text)
                          : Fluttertoast.showToast(
                        msg: 'All fields are required',
                        textColor: Colors.red,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      backgroundColor: Colors.blue[700],
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don`t have an account?',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

