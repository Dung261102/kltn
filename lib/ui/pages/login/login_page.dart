import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_page.dart'; // Chuyển đến trang đăng ký
import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:glucose_real_time/rest/rest_api.dart';
import 'package:glucose_real_time/services/glucose_service.dart';
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
  final GlucoseService _glucoseService = GlucoseService();
  List<String> emailHistory = [];

  @override
  void initState() {
    super.initState();
    _loadEmailHistory();
  }

  Future<void> _loadEmailHistory() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      emailHistory = _sharedPreferences.getStringList('email_history') ?? [];
    });
  }

  // Thêm hàm xoá email khỏi lịch sử
  Future<void> _removeEmailFromHistory(String email) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      emailHistory.remove(email);
    });
    await _sharedPreferences.setStringList('email_history', emailHistory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
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
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Welcome back you've been missed!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 35),
                  // Trường email
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return emailHistory;
                      }
                      return emailHistory.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _emailController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return FormFields(
                        controller: controller,
                        focusNode: focusNode,
                        data: Icons.email,
                        txtHint: 'Email',
                        obsecure: false,
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 320,
                            constraints: BoxConstraints(maxHeight: 220),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => onSelected(option),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                          child: Text(
                                            option,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      tooltip: 'Xoá email này',
                                      onPressed: () => _removeEmailFromHistory(option),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
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
                        color: Colors.white,
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
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold),
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
                        Text(
                          "Don't have an account? ",
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
                        Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
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

  // Hàm xử lý đăng nhập
  doLogin(String email, String password) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    var res = await userLogin(email.trim(), password.trim());

    if (res['success']) {
      String userEmail = res['user'][0]['email'];
      int userId = res['user'][0]['id'];
      String username = res['user'][0]['name'] ?? 'User'; // Lấy username từ response
      
      // Lưu thông tin đăng nhập
      await _sharedPreferences.setInt('userid', userId);
      await _sharedPreferences.setString('usermail', userEmail);
      await _sharedPreferences.setString('username', username);
      
      // Lưu trạng thái đã đăng nhập
      await _sharedPreferences.setBool('isLoggedIn', true);

      // Lưu email vào history
      List<String> emailHistory = _sharedPreferences.getStringList('email_history') ?? [];
      if (!emailHistory.contains(userEmail)) {
        emailHistory.add(userEmail);
        await _sharedPreferences.setStringList('email_history', emailHistory);
      }

      // Load lại dữ liệu glucose và profile từ local storage
      await _glucoseService.loadUserDataOnLogin();

      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Fluttertoast.showToast(
        msg: 'Email and password not valid!',
        textColor: Colors.red,
      );
    }
  }
}
