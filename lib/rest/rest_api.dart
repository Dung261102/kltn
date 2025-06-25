//Chỉ chứa các hàm liên quan đến HTTP (GET, POST, PUT, DELETE).
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../ui/theme/test/utils.dart'; // Đảm bảo Utils.baseUrl hợp lệ

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
    throw Exception('Lỗi server: ${response.statusCode} - ${response.body}');
  }
}

// Hàm đăng ký
Future<Map<String, dynamic>> userRegister(
    String username,
    String email,
    String password,
    // String phone,
    String dob,
    // String address
    ) async {
  final response = await http.post(
    Uri.parse('${Utils.baseUrl}/user/register'),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: jsonEncode({
      'name': username,
      'email': email,
      'password': password,
      // 'phone': phone,
      'dob': dob,
      // 'address': address
    }),
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
    throw Exception('Lỗi server: ${response.statusCode} - ${response.body}');
  }
}

Future<void> sendGlucoseDataToBackend({
  required String deviceId,
  required int glucoseValue,
}) async {
  final url = Uri.parse('${Utils.baseUrl}/events'); // Đổi cho đúng backend
  final body = jsonEncode({
    'device_id': deviceId,
    'type': 'Glucose',
    'value': glucoseValue,
  });

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: body,
    );

    if (response.statusCode == 201) {
      print('✅ Gửi dữ liệu glucose thành công: ${response.body}');
    } else {
      print('❌ Lỗi gửi dữ liệu: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('❗ Lỗi kết nối backend: $e');
  }
}