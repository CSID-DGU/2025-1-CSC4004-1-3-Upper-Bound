import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'widgets/root_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dementia App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootScreen(camera: cameras.first),
    );
  }
}
