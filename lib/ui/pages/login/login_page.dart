import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_page.dart'; // Chuyển đến trang đăng ký
import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:glucose_real_time/rest/rest_api.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/form_fields_widgets.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late SharedPreferences _sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text(
                  "Login here",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Welcome back you've been missed!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: 35),

                // Trường email
                FormFields(
                  controller: _emailController,
                  data: Icons.email,
                  txtHint: 'Email',
                  obsecure: false,
                ),

                // Trường password
                FormFields(
                  controller: _passwordController,
                  data: Icons.lock,
                  txtHint: 'Password',
                  obsecure: true,
                ),

                SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 13,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Nút đăng nhập
                ElevatedButton(
                  onPressed: () {
                    if (_emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      doLogin(_emailController.text, _passwordController.text);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'All fields are required',
                        textColor: Colors.red,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                SizedBox(height: 20),

                // Chuyển sang đăng ký
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: TextStyle(fontSize: 14)),
                      Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
    _sharedPreferences = await SharedPreferences.getInstance();
    var res = await userLogin(email.trim(), password.trim());

    if (res['success']) {
      String userEmail = res['user'][0]['email'];
      int userId = res['user'][0]['id'];
      _sharedPreferences.setInt('userid', userId);
      _sharedPreferences.setString('usermail', userEmail);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Email and password not valid!',
        textColor: Colors.red,
      );
    }
  }
}
