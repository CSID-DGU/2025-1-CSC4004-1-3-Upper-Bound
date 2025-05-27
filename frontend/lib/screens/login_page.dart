import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    final result = await AuthService.login(id, password);
    print('ServerCheck: 서버 연결 시도 완료, 결과: $result');


    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', id);  // 로그인 성공 시 id 저장

      Navigator.pushReplacementNamed(context, '/root');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 실패')),
      );
    }
  }

  void _goToSignup() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Id', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _goToSignup,
              child: const Text('sign up', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
