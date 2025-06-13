import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../rest/rest_api.dart'; // Gọi API đăng ký
import 'login_page.dart';            // Trang đăng nhập

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  // Controller cho các ô nhập liệu
  final TextEditingController email = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  // Key để validate form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Nền toàn màn hình
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: Colors.white, // Giao diện form nền trắng
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey, // Form validation
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 25),

                  _buildField(email, Icons.email, 'Email'),
                  _buildField(username, Icons.person, 'Username'),
                  _buildField(dob, Icons.calendar_today, 'Date of Birth'),
                  _buildField(phone, Icons.phone, 'Phone'),
                  _buildField(address, Icons.home, 'Address'),
                  _buildField(password, Icons.lock, 'Password', isPassword: true),
                  _buildField(confirmPassword, Icons.lock_outline, 'Confirm Password', isPassword: true),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (password.text != confirmPassword.text) {
                          Fluttertoast.showToast(
                            msg: "Passwords do not match",
                            textColor: Colors.red,
                          );
                          return;
                        }

                        // Gọi API đăng ký
                        doRegister(
                          username.text,
                          email.text,
                          password.text,
                          phone.text,
                          dob.text,
                          address.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget xây dựng các trường nhập liệu
  Widget _buildField(TextEditingController controller, IconData icon, String hint, {bool isPassword = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$hint is required';
          }
          return null;
        },
      ),
    );
  }

  // Hàm gọi API đăng ký
  Future<void> doRegister(
      String username,
      String email,
      String password,
      String phone,
      String dob,
      String address,
  ) async {
    var res = await userRegister(username, email, password, phone, dob, address); // Gọi API

    if (res['success']) {
      Fluttertoast.showToast(msg: 'Registration successful', textColor: Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      Fluttertoast.showToast(msg: 'Registration failed, try again', textColor: Colors.red);
    }
  }
}
