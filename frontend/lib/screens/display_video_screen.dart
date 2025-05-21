import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';

class DisplayVideoScreen extends StatelessWidget {
  final String videoPath;

  const DisplayVideoScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('촬영한 영상')),
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: size.width,
            height: size.height * 0.6,
            child: VideoPlayerWidget(videoPath: videoPath),
          ),
        ),
      ),
    );
  }
}