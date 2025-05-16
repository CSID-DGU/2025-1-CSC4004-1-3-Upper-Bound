import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heightController = TextEditingController();


  void _signup() async {
    final id = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final heightText = _heightController.text.trim();

    if (id.isEmpty || password.isEmpty || heightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요')),
      );
      return;
    }

    final height = int.tryParse(heightText);
    if (height == null || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 키를 입력해주세요')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://your-backend-url.com/api/signup'), // ← 실제 API 주소로 변경
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'password': password,
          'height': height,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        final msg = jsonDecode(response.body)['message'] ?? '회원가입 실패';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  void _goToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sign up', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Id', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
