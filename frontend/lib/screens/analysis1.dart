import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';

import 'analysis2.dart';

class Analysis1Page extends StatefulWidget {
  final CameraDescription? camera;

  const Analysis1Page({Key? key, this.camera}) : super(key: key);

  @override
  _Analysis1PageState createState() => _Analysis1PageState();
}

class _Analysis1PageState extends State<Analysis1Page> {
  VideoPlayerController? _controller;

  double palmMove = 95;
  double shoulderOuter = 3;
  double shoulderInner = 75;
  double elbowAngle = 1;

  bool isSideAnalysisSelected = true; // 탭 상태 관리

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/video.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget buildSliderRow(String label, double value, double min, double max,
      Function(double) onChanged,
      {Color color = Colors.blue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: color,
          inactiveColor: Colors.grey[300],
        ),
        Text('${value.toStringAsFixed(1)}°'),
      ],
    );
  }

  Widget _buildAnalysisWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 탭: 측면분석 / 분석그래프
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSideAnalysisSelected = true;
                  });
                },
                child: Text(
                  '측면분석',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSideAnalysisSelected ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSideAnalysisSelected = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Analysis2Page(camera: widget.camera),
                      ),
                    );
                  });
                },
                child: Text(
                  '분석그래프',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSideAnalysisSelected ? Colors.grey : Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 영상 화면
          _controller?.value.isInitialized == true
              ? AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          )
              : const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),

          // 분석 지표 슬라이더
          buildSliderRow('팔꿈치 이동 정도(cm)', palmMove, 90, 110, (value) {
            setState(() {
              palmMove = value;
            });
          }),
          buildSliderRow('어깨 외전 각도(°)', shoulderOuter, 0, 5, (value) {
            setState(() {
              shoulderOuter = value;
            });
          }, color: Colors.red),
          buildSliderRow('어깨 내전 각도(°)', shoulderInner, 60, 90, (value) {
            setState(() {
              shoulderInner = value;
            });
          }, color: Colors.red),
          buildSliderRow('팔꿈치 굴곡 범위의 차(°)', elbowAngle, 0, 5, (value) {
            setState(() {
              elbowAngle = value;
            });
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 화면'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalysisWidget(),
          ],
        ),
      ),
    );
  }
}
