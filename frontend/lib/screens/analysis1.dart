import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'analysis2.dart';

class Analysis1Page extends StatefulWidget {
  const Analysis1Page({Key? key}) : super(key: key);

  @override
  State<Analysis1Page> createState() => _Analysis1PageState();
}

class _Analysis1PageState extends State<Analysis1Page> {
  VideoPlayerController? _controller;

  double palmMove = 95;
  double shoulderOuter = 3;
  double shoulderInner = 75;
  double elbowAngle = 1;

  bool _isLoading = true;
  String? _rawJson;
  String? _summaryJson;
  String? _error;

  String? userId;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/video.mp4')
      ..initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        setState(() {
          _error = "Video initialization error: $error";
        });
      });

    loadUserIdAndFetchData();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    setState(() {
      userId = id;
    });

    if (userId != null) {
      await fetchAnalysisData(userId!);
    } else {
      setState(() {
        _error = "User ID not found.";
        _isLoading = false;
      });
    }
  }

  Future<void> fetchAnalysisData(String userId) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _rawJson = null;
      _summaryJson = null;
    });

    try {
      final url = Uri.parse('http://43.201.78.241:3000/pushup/analytics?userId=$userId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _rawJson = jsonEncode(data);
          _summaryJson = jsonEncode(data['summary']);

          final summary = data['summary'];
          palmMove = (summary['elbow_motion'] as num).toDouble();
          shoulderOuter = (summary['shoulder_abduction'] as num).toDouble();
          elbowAngle = (summary['elbow_flexion'] as num).toDouble();
          shoulderInner = 75;

          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'API error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Fetch error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_controller != null && _controller!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              else
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // 필요하면 측면분석 기능 추가
                    },
                    child: const Text(
                      '측면분석',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Analysis2Page()),
                      );
                    },
                    child: const Text(
                      '정면분석',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              buildSliderRow('팔꿈치 이동 정도(cm)', palmMove, 90, 110, (value) {
                setState(() {
                  palmMove = value;
                });
              }),
              buildSliderRow('어깨 외전 각도(°)', shoulderOuter, 0, 50, (value) {
                setState(() {
                  shoulderOuter = value;
                });
              }, color: Colors.red),
              buildSliderRow('어깨 내전 각도(°)', shoulderInner, 60, 90, (value) {
                setState(() {
                  shoulderInner = value;
                });
              }, color: Colors.red),
              buildSliderRow('팔꿈치 굴곡 범위의 차(°)', elbowAngle, 0, 110, (value) {
                setState(() {
                  elbowAngle = value;
                });
              }),
              const SizedBox(height: 30),
              const Text('■ API 응답 전체 JSON', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_rawJson ?? '없음', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 20),
              const Text('■ summary JSON', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_summaryJson ?? '없음', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSliderRow(
      String label, double value, double min, double max, Function(double) onChanged,
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
        Text('${value.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
