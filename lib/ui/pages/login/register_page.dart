import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../rest/rest_api.dart'; // Gọi API đăng ký
import 'login_page.dart';            // Trang đăng nhập
import '../../widgets/form_fields_widgets.dart'; // Import FormFields widget

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
  final TextEditingController height = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final TextEditingController age = TextEditingController();
  late SharedPreferences _sharedPreferences;

  // Key để validate form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(25),
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 25),
                  FormFields(
                    controller: email,
                    data: Icons.email,
                    txtHint: 'Email',
                    obsecure: false,
                  ),
                  FormFields(
                    controller: username,
                    data: Icons.person,
                    txtHint: 'Username',
                    obsecure: false,
                  ),
                  FormFields(
                    controller: dob,
                    data: Icons.calendar_today,
                    txtHint: 'Date of Birth (optional)',
                    obsecure: false,
                  ),
                  FormFields(
                    controller: phone,
                    data: Icons.phone,
                    txtHint: 'Phone (optional)',
                    obsecure: false,
                  ),
                  FormFields(
                    controller: address,
                    data: Icons.home,
                    txtHint: 'Address (optional)',
                    obsecure: false,
                  ),
                  FormFields(
                    controller: height,
                    data: Icons.height,
                    txtHint: 'Height (cm, optional)',
                    obsecure: false,
                  ),
                  FormFields(
                    controller: weight,
                    data: Icons.monitor_weight,
                    txtHint: 'Weight (kg, optional)',
                    obsecure: false,
                  ),
                  FormFields(
                    controller: age,
                    data: Icons.person_outline,
                    txtHint: 'Age (optional)',
                    obsecure: false,
                  ),
                  FormFields(
                    controller: password,
                    data: Icons.lock,
                    txtHint: 'Password',
                    obsecure: true,
                  ),
                  FormFields(
                    controller: confirmPassword,
                    data: Icons.lock_outline,
                    txtHint: 'Confirm Password',
                    obsecure: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (email.text.isEmpty || username.text.isEmpty || password.text.isEmpty || confirmPassword.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Please fill in all required fields",
                          textColor: Colors.red,
                        );
                        return;
                      }
                      if (password.text != confirmPassword.text) {
                        Fluttertoast.showToast(
                          msg: "Passwords do not match",
                          textColor: Colors.red,
                        );
                        return;
                      }
                      doRegister(
                        username.text,
                        email.text,
                        password.text,
                        phone.text,
                        dob.text,
                        address.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black26,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black26,
                                offset: Offset(0, 1),
                              ),
                            ],
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
    var res = await userRegister(username, email, password, phone, dob, address);

    if (res['success']) { // nếu đăng ký thành công
      // Save username and body information to SharedPreferences
      await _sharedPreferences.setString('username', username);
      if (height.text.isNotEmpty) await _sharedPreferences.setDouble('height', double.tryParse(height.text) ?? 0.0);
      if (weight.text.isNotEmpty) await _sharedPreferences.setDouble('weight', double.tryParse(weight.text) ?? 0.0);
      if (age.text.isNotEmpty) await _sharedPreferences.setInt('age', int.tryParse(age.text) ?? 0);
      // Lưu thông tin đăng nhập nếu API trả về user data
      if (res['user'] != null) {
        await _sharedPreferences.setInt('userid', res['user']['id']);
        await _sharedPreferences.setString('usermail', email);
        await _sharedPreferences.setBool('isLoggedIn', true);
      }
      // Hiển thị màn hình thông báo thành công
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SuccessDialog(),
      );
    } else {
      Fluttertoast.showToast(msg: 'Registration failed, try again', textColor: Colors.red);
    }
  }
}

// Thêm widget SuccessDialog ở cuối file
class SuccessDialog extends StatefulWidget {
  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
          const SizedBox(height: 16),
          Text(
            'Registration Successful!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your account has been created.\nRedirecting to login...',
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
