import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';

class DisplayVideoScreen extends StatelessWidget {
  final String videoPath;

  const DisplayVideoScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('촬영한 영상')),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayerWidget(videoPath: videoPath),
        ),
      ),
    );
  }
}
