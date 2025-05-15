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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final previewSize = _controller.value.previewSize!;
            final previewAspectRatio = previewSize.height / previewSize.width;

            return Center(
              child: AspectRatio(
                aspectRatio: previewAspectRatio,
                child: CameraPreview(_controller),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleRecording,
        child: Transform.rotate(
          angle: -1.5708, // -90도 (radian 단위)
          child: Icon(_isRecording ? Icons.stop : Icons.videocam),
        ),
      ),
    );
  }

}
