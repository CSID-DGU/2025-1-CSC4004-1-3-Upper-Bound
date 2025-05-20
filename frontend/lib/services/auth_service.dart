import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://43.201.78.241:3000';

  static Future<bool> login(String userId, String password) async {
    final url = Uri.parse('$baseUrl/user/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('로그인 성공: ${responseData['message']}');
        return true;
      } else {
        print('로그인 실패: ${response.body}');
        print('statusCode: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('로그인 오류: $e');
      return false;
    }
  }

  static Future<bool> signup(String userId, String password, int height) async {
    final url = Uri.parse('$baseUrl/user/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'password': password,
          'height': height,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('회원가입 성공');
        return true;
      } else {
        print('회원가입 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('회원가입 오류: $e');
      return false;
    }
  }
}