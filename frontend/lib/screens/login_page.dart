import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 실제 로그인 처리 로직 (예: 서버 통신)이 이 자리에 들어감
    print('로그인 요청: $email / $password');

    // 로그인 성공 시 루트 화면으로 이동
    Navigator.pushReplacementNamed(context, '/root');
  }


  void _goToSignup() {
    Navigator.pushNamed(context, '/signup');
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
            const Text('Log in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
