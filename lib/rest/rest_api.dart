import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../ui/theme/test/utils.dart'; // Thêm nếu cần dùng Utils.baseUrl

// Hàm đăng nhập
Future<Map<String, dynamic>> userLogin(String email, String password) async {
  final response = await http.post(
    Uri.parse('${Utils.baseUrl}/user/login'),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: jsonEncode({'email': email, 'password': password}),
  );

  print('STATUS CODE: ${response.statusCode}');
  print('RESPONSE BODY: ${response.body}');

  if (response.statusCode == 200) {
    try {
      final decodedData = jsonDecode(response.body);
      return decodedData;
    } catch (e) {
      throw Exception("Lỗi xử lý JSON: $e");
    }
  } else {
    throw Exception('Lỗi server: ${response.statusCode}');
  }
}



// Hàm đăng ký
Future<Map<String, dynamic>> userRegister(String username, String email, String password, String phone) async {
  final response = await http.post(
    Uri.parse('${Utils.baseUrl}/user/register'),
    headers: {
      "Content-Type": "application/json", // ✅ Bắt buộc
      "Accept": "application/json"
    },
    body: jsonEncode({
      'name': username,
      'email': email,
      'password': password,
      'phone': phone
    }),
  );

  var decodedData = jsonDecode(response.body);
  return decodedData;
}
