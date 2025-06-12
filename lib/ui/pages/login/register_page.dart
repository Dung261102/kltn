// Import các thư viện cần thiết từ Flutter và các gói bên ngoài
import 'package:flutter/material.dart';                    // Giao diện Flutter
import 'package:fluttertoast/fluttertoast.dart';          // Thư viện hiển thị toast message (popup thông báo)

// Import các file trong project
import '../../../rest/rest_api.dart';                      // Gọi API đăng ký người dùng
import '../../widgets/form_fields_widgets.dart';          // Widget custom cho các ô nhập liệu
import 'login_page.dart';                                 // Trang đăng nhập

// Tạo màn hình RegisterPage là một StatefulWidget vì có trạng thái thay đổi (form nhập liệu)
class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState(); // Trả về State tương ứng
  }
}

// Lớp chứa logic và giao diện của trang đăng ký
class RegisterPageState extends State<RegisterPage> {
  // Tạo các controller để lấy dữ liệu từ các ô nhập liệu
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  // Khóa để kiểm tra tính hợp lệ của form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Hàm build giao diện
  @override
  Widget build(BuildContext context) {
    final heightOfScreen = MediaQuery.of(context).size.height;
    final widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      body: Center(
        child: SingleChildScrollView(
          child: 
          Container(
            width: widthOfScreen > 400 ? 400 : widthOfScreen * 0.95,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 8),
              
                SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(email, 'Email', Icons.email, false),
                      SizedBox(height: 16),
                      _buildField(username, 'Name', Icons.person, false),
                      SizedBox(height: 16),
                      _buildField(dob, 'Date of Birth', Icons.calendar_today, false),
                      SizedBox(height: 16),
                      _buildField(phone, 'Phone Number', Icons.phone, false),
                      SizedBox(height: 16),
                      _buildField(address, 'Address', Icons.home, false),
                      SizedBox(height: 16),
                      _buildField(password, 'Password', Icons.lock, true),
                      SizedBox(height: 16),
                      _buildField(confirmPassword, 'Confirm Password', Icons.lock_outline, true),
                    ],
                  ),
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (username.text.isNotEmpty &&
                          password.text.isNotEmpty &&
                          email.text.isNotEmpty &&
                          phone.text.isNotEmpty &&
                          address.text.isNotEmpty &&
                          dob.text.isNotEmpty &&
                          confirmPassword.text.isNotEmpty) {
                        if (password.text != confirmPassword.text) {
                          Fluttertoast.showToast(
                            msg: 'Passwords do not match',
                            textColor: Colors.red,
                          );
                          return;
                        }
                        doRegister(
                          username.text,
                          email.text,
                          password.text,
                          phone.text,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: 'All fields are required',
                          textColor: Colors.red,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return Colors.transparent;
                      }),
                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A8DFF), Color(0xFF4F6BED)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Already have an account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Or Login',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, bool obsecure) {
    return TextFormField(
      controller: controller,
      obscureText: obsecure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue[300]),
        hintText: hint,
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
      style: TextStyle(fontSize: 16),
    );
  }

  Widget _socialButton(String assetPath) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(assetPath, width: 22, height: 22),
      ),
    );
  }

  // Hàm xử lý khi nhấn nút đăng ký
  Future<void> doRegister(
      String username, String email, String password, String phoneno) async {
    var res = await userRegister(username, email, password, phoneno); // Gọi API đăng ký
    if (res['success']) {
      // Nếu thành công, chuyển sang trang đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Nếu thất bại, hiển thị thông báo lỗi
      Fluttertoast.showToast(
        msg: 'Try again ?',
        textColor: Colors.red,
      );
    }
  }
}
