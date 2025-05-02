import 'package:flutter/material.dart';
import 'widgets/root_screen.dart';

void main() {
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
      home: RootScreen(),
    );
  }
}