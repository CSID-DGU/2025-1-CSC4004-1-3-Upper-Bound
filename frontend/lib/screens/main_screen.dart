import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'display_video_screen.dart';

class MainScreen extends StatefulWidget {
  final CameraDescription camera;

  const MainScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    try {
      await _initializeControllerFuture;

      if (_isRecording) {
        final XFile videoFile = await _controller.stopVideoRecording();
        setState(() => _isRecording = false);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayVideoScreen(videoPath: videoFile.path),
          ),
        );
      } else {
        await _controller.prepareForVideoRecording();
        await _controller.startVideoRecording();
        setState(() => _isRecording = true);
      }
    } catch (e) {
      print('녹화 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메인 페이지')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleRecording,
        child: Icon(_isRecording ? Icons.stop : Icons.videocam),
      ),
    );
  }
}
