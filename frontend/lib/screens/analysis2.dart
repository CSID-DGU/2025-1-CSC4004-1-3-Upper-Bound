import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Analysis2Page extends StatelessWidget {
  final CameraDescription? camera;

  const Analysis2Page({Key? key, this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 그래프'),
      ),
      body: Center(
        child: Text(
          '그래프 화면입니다.\n카메라 상태: ${camera != null ? "준비됨" : "없음"}',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
