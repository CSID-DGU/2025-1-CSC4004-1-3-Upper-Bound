import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'widgets/root_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultCamera = cameras.first;

    return MaterialApp(
      title: 'Dementia App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/root': (context) => RootScreen(camera: defaultCamera),
      },
    );
  }
}
