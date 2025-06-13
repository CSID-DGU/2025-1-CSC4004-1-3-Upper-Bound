import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'analysis2.dart';
import '../globals/auth_user.dart';

class Analysis1Page extends StatefulWidget {
  final int analysisId;
  const Analysis1Page({super.key, required this.analysisId});

  @override
  State<Analysis1Page> createState() => _Analysis1PageState();
}

class _Analysis1PageState extends State<Analysis1Page> {
  double palmMove = 95;
  double shoulderOuter = 3;
  double elbowAngle = 1;
  double lowerBodyScore = 0;

  int repetitionCount = 0;
  double score = 0.0;

  bool _isLoading = true;
  String? _error;

  String? userId;
  String? selectedVideoUrl;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchData();
  }

  Future<void> _initVideo(String url) async {
    print(" Trying to load video from: $url"); // 로그 추가
    await _videoController?.pause();
    await _videoController?.dispose();

    _videoController = VideoPlayerController.network(url);
    _videoController!.addListener(() {
      if (_videoController!.value.hasError) {
        print('❌ Video player error: ${_videoController!.value.errorDescription}');
      }
    });

    try {
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      if (mounted) {
        setState(() {});
        _videoController!.play();
      }
    } catch (e) {
      print('❌ Video initialize error: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    setState(() {
      userId = id;
    });

    if (userId != null) {
      print("✅ userId found: $userId");
      await fetchAnalysisData(userId!);
    } else {
      print("⚠️ userId is null. fetchAnalysisData() will not be called.");
      setState(() {
        _error = "User ID not found.";
        _isLoading = false;
      });
    }

  }

  Future<void> fetchAnalysisData(String userId) async {
    print("fecthAnalysisData 시작");
    setState(() {
      _isLoading = true;
      _error = null;
      selectedVideoUrl = null;
    });

    try {
      final detailUrl = Uri.parse(
          '$urlIp/pushup/analytics?analysisId=${widget.analysisId}');
      final detailResponse = await http.get(detailUrl);

      if (detailResponse.statusCode == 200) {
        final detailData = jsonDecode(detailResponse.body);

        final summaryRaw = detailData['summary'];
        if (summaryRaw == null) {
          setState(() {
            _error = 'summary 데이터가 없습니다.';
            _isLoading = false;
          });
          return;
        }

        final summary =
        (summaryRaw is String) ? jsonDecode(summaryRaw) : summaryRaw;

        String? videoUrlFromApi = detailData['video_url'];
        if (videoUrlFromApi != null && videoUrlFromApi.isNotEmpty) {
          selectedVideoUrl = videoUrlFromApi;
          await _initVideo(videoUrlFromApi);
        } else {
          selectedVideoUrl = '$urlIp/pushup/video/${widget.analysisId}';
          print(' selectedVideoUrl: $selectedVideoUrl');

          await _initVideo(selectedVideoUrl!);
        }

        setState(() {
          palmMove = (summary['elbow_motion'] as num?)?.toDouble() ?? 0.0;
          shoulderOuter =
              ((summary['shoulder_abduction'] as num?)?.toDouble().abs()) ?? 0.0;
          elbowAngle = (summary['elbow_flexion'] as num?)?.toDouble() ?? 0.0;
          lowerBodyScore =
              (summary['lower_body_alignment_score'] as num?)?.toDouble() ?? 0.0;

          repetitionCount = (detailData['repetition_count'] as int?) ?? 0;
          score = (detailData['score'] as num?)?.toDouble() ?? 0.0;

          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '상세 API 에러: ${detailResponse.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      print('Fetch error 발생: $e');
      print('Stacktrace: $stacktrace');

      setState(() {
        _error = 'Fetch error: $e';
        _isLoading = false;
      });
    }
  }

  Widget buildVideoPlayerBox() {
    if (selectedVideoUrl == null) {
      return Container(
        height: 200,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Text('영상 URL이 없습니다.', style: TextStyle(color: Colors.red)),
      );
    }

    if (_videoController == null) {
      return Container(
        height: 200,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (!_videoController!.value.isInitialized) {
      return Container(
        height: 200,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_videoController!.value.hasError) {
      return Container(
        height: 200,
        color: Colors.black12,
        alignment: Alignment.center,
        child: Text('영상 재생 오류: ${_videoController!.value.errorDescription}',
            style: const TextStyle(color: Colors.red)),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }

  String getLowerBodyGuide(double value) {
    if (value >= 20 && value <= 90) {
      return '하체 정렬이 불균형한 상태입니다. 자세를 곧게 펴는 것이 좋습니다.';
    } else if (value >= 0 && value < 20) {
      return '하체 균형이 잘 잡혀있습니다.';
    } else {
      return 'Error!';
    }
  }

  String getPalmMoveGuide(double value) {
    if (value < 80) {
      return '하체가 안정적으로 정렬되어 있어 균형이 잘 잡혀 있습니다.';
    } else if (value >= 80 && value <= 90) {
      return '푸쉬업 가동범위가 적절합니다.';
    } else {
      return 'Error!';
    }
  }

  String getShoulderOuterGuide(double value) {
    if (value < 20 && value >= 0) {
      return '손목 간격이 너무 좁은 경우 손목에 부하가 증가할 수 있습니다.';
    } else if (value >= 20 && value <= 60) {
      return '어깨 외전 각도가 적절합니다.';
    } else if (value > 60 && value <= 90) {
      return '손목 간격이 너무 넓은 경우 어깨충돌증후군 발생 위험이 있습니다.';
    } else {
      return 'Error!';
    }
  }

  String getElbowAngleGuide(double value) {
    if (value < 80) {
      return '팔꿈치가 손목보다 뒤에 있을 경우 팔꿈치에 부하가 증가할 수 있습니다.';
    } else if (value >= 80 && value <= 100) {
      return '팔꿈치와 손목이 잘 정렬되어 있습니다.';
    } else if (value > 100 && value <= 180) {
      return '팔꿈치가 손목보다 앞에 있을 경우 어깨와 손목에 부하가 증가할 수 있습니다.';
    } else {
      return 'Error!';
    }
  }

  Widget buildInbodyBar({
    required double value,
    required double min,
    required double anomalyMin,
    required double anomalyMax,
    required double max,
    required String unit,
    bool isReverse = false,
    String widgetName = '', // 구분자 추가
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 32.0;
    final double barWidth = screenWidth - horizontalPadding;

    double calcValue = isReverse ? (max + min - value) : value;
    double calcMin = min;
    double calcMax = max;

    if (isReverse) {
      calcMin = max;
      calcMax = min;
    }

    double totalRange = calcMax - calcMin;

    double normalizedValue = ((calcValue - calcMin) / totalRange).clamp(0.0, 1.0);
    double normalizedAnomalyMin = ((anomalyMin - calcMin) / totalRange).clamp(0.0, 1.0);
    double normalizedAnomalyMax = ((anomalyMax - calcMin) / totalRange).clamp(0.0, 1.0);

    bool hideAnomalyMax = (anomalyMax == max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: barWidth,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Positioned(
              left: barWidth * normalizedAnomalyMin,
              top: 0,
              width: barWidth * (normalizedAnomalyMax - normalizedAnomalyMin),
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Positioned(
              left: (barWidth * normalizedValue) - 12,
              top: -18,
              child: const Icon(Icons.arrow_drop_down, color: Colors.red, size: 28),
            ),
            Positioned(
              left: (barWidth * normalizedValue) - 16,
              top: 0,
              child: Text(
                '${value.toStringAsFixed(1)}$unit',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 30,
              child: Text(
                min.toInt().toString(),
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Positioned(
              left: barWidth * normalizedAnomalyMin - 10,
              top: 30,
              child: Text(
                anomalyMin.toInt().toString(),
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (!hideAnomalyMax)
              Positioned(
                left: barWidth * normalizedAnomalyMax - 20,
                top: 30,
                child: Text(
                  anomalyMax.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            Positioned(
              left: (widgetName == 'elbowAngle') ? barWidth - 30 : barWidth - 20,
              top: 30,
              child: Text(
                max.toInt().toString(),
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
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
            ? Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '측면분석',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Analysis2Page(analysisId: widget.analysisId),
                        ),
                      );
                    },
                    child: const Text(
                      '분석그래프',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              buildVideoPlayerBox(),
              const SizedBox(height: 15),
              Text(
                '반복 횟수: $repetitionCount 회',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '총점: ${score.toStringAsFixed(1)} 점',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Text(
                    '하체 정렬 (°)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              buildInbodyBar(
                value: lowerBodyScore,
                min: 0,
                anomalyMin: 0,
                anomalyMax: 20,
                max: 90,
                unit: '°',
              ),
              const SizedBox(height: 20),
              Text(
                getLowerBodyGuide(lowerBodyScore),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Text(
                    '가동 범위 (°)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 20),
              buildInbodyBar(
                value: palmMove,
                min: 0,
                anomalyMin: 80,
                anomalyMax: 90,
                max: 90,
                unit: '°',
              ),
              const SizedBox(height: 20),
              Text(
                getPalmMoveGuide(palmMove),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Text(
                    '어깨 외전 각도 (°)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 20),
              buildInbodyBar(
                value: shoulderOuter.abs(),
                min: 0,
                anomalyMin: 20,
                anomalyMax: 60, // 최대 이상값 60으로 변경
                max: 90,
                unit: '°',
              ),
              const SizedBox(height: 20),
              Text(
                getShoulderOuterGuide(shoulderOuter.abs()),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Text(
                    '전완 각도 (°)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 20),
              buildInbodyBar(
                value: elbowAngle,
                min: 0,
                anomalyMin: 80,
                anomalyMax: 100, // 최대 이상값 100으로 변경
                max: 180,
                unit: '°',
                widgetName: 'elbowAngle', // 위치 조정용
              ),
              const SizedBox(height: 20),
              Text(
                getElbowAngleGuide(elbowAngle),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
