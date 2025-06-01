import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'display_video_screen.dart';
import '../utils/hand_guide_painter.dart';
import '../services/video_upload_service.dart';
import '../globals/auth_user.dart';
import 'analysis1.dart';

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
  int _countdown = 0;
  bool _isCountingDown = false;
  bool _isUploading = false;

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
        setState(() => _isUploading = true);

// analysisId를 받도록 수정
        final analysisId = await VideoUploadService.uploadVideo(videoFile.path, currentUserId ?? '');
        print('받은 analysisId: $analysisId');


        setState(() => _isUploading = false);
        if (!mounted) return;

        if (analysisId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Analysis1Page(analysisId: analysisId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('업로드 실패')),
          );
        }

      } else {
        // 카운트다운 시작
        setState(() {
          _isCountingDown = true;
          _countdown = 5;
        });

        for (int i = 4; i >= 0; i--) {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            _countdown = i;
          });
        }

        setState(() {
          _isCountingDown = false;
        });

        // 3초 후 녹화 시작
        await _controller.prepareForVideoRecording();
        await _controller.startVideoRecording();
        setState(() => _isRecording = true);
      }
    } catch (e) {
      print('녹화 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('녹화 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('카메라 초기화 중 오류가 발생했습니다: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            final previewSize = _controller.value.previewSize;
            if (previewSize == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final previewAspectRatio = previewSize.height / previewSize.width;

            return Center(
              child: AspectRatio(
                aspectRatio: previewAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller),

                    // 가이드라인 오버레이
                    CustomPaint(
                      painter: HandGuidePainter(),
                    ),

                    // 카운트다운 오버레이
                    if (_isCountingDown)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        alignment: Alignment.center,
                        child: Transform.rotate(
                          angle: 1.5708, // -90도
                          child: Text(
                            '$_countdown',
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (_isUploading)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        alignment: Alignment.center,
                        child: Transform.rotate(
                          angle: 1.5708,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 20),
                              Text(
                                '업로드 중...',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                  ],
                ),
              ),
            );

          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: _toggleRecording,
          backgroundColor: Colors.grey[300],
          shape: const CircleBorder(),
          child: Transform.rotate(
            angle: -1.5708,
            child: Icon(
              _isRecording ? Icons.stop : Icons.videocam,
              color: Colors.black,
              size: 40,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
