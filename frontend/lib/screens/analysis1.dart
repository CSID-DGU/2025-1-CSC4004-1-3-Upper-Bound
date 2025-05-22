import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'analysis2.dart';
import 'display_video_screen.dart';

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
  String? _rawJson;
  String? _summaryJson;
  String? _error;

  String? userId;

  List<String> videoUrls = [
    'http://43.201.78.241:3000/pushup/upload',
  ];

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchData();
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
      final detailUrl = Uri.parse(
          'http://43.201.78.241:3000/pushup/analytics?analysisId=${widget.analysisId}');
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

        setState(() {
          _rawJson = jsonEncode(detailData);
          _summaryJson = jsonEncode(summary);

          palmMove = (summary['elbow_motion'] as num?)?.toDouble() ?? 0.0;
          shoulderOuter =
              (summary['shoulder_abduction'] as num?)?.toDouble() ?? 0.0;
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

  String getPalmMoveGuide(double value) {
    if (value < 40) {
      return '팔꿈치를 몸에서 좀 더 벌려 공간을 확보하세요.';
    } else if (value > 90) {
      return '팔꿈치를 몸 쪽으로 살짝 모아 긴장을 줄이세요.';
    } else {
      return '팔꿈치 이동 범위가 적절합니다.';
    }
  }

  String getShoulderOuterGuide(double value) {
    if (value < 20) {
      return '팔을 몸 옆으로 곧게 들어 올려 주세요.';
    } else if (value > 60) {
      return '팔을 들어 올릴 때 어깨가 과도하게 올라가지 않도록 조절하세요.';
    } else {
      return '어깨 외전 각도가 적절합니다.';
    }
  }

  String getElbowAngleGuide(double value) {
    if (value < 60) {
      return '팔꿈치를 더 깊게 굽혀 가슴 쪽으로 당기세요.';
    } else if (value > 110) {
      return '팔꿈치 굴곡 각도를 적절히 조절하세요.';
    } else {
      return '팔꿈치 굴곡 범위가 적절합니다.';
    }
  }

  Widget buildInbodyBar({
    required double value,
    required double min,
    required double lowStandard,
    required double highStandard,
    required double max,
    required String unit,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 32.0;
    final double barWidth = screenWidth - horizontalPadding;

    double totalRange = max - min;
    double lowRange = (lowStandard - min) / totalRange;
    double stdRange = (highStandard - lowStandard) / totalRange;
    double highRange = (max - highStandard) / totalRange;

    double normalizedValue = ((value - min) / totalRange).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                Container(
                  width: barWidth * lowRange,
                  height: 20,
                  color: Colors.grey[200],
                ),
                Container(
                  width: barWidth * stdRange,
                  height: 20,
                  color: Colors.blue[200],
                ),
                Container(
                  width: barWidth * highRange,
                  height: 20,
                  color: Colors.grey[200],
                ),
              ],
            ),
            Positioned(
              left: (barWidth * normalizedValue - 12).clamp(0.0, barWidth - 40),
              top: -18,
              child: const Icon(Icons.arrow_drop_down, color: Colors.red, size: 28),
            ),
            Positioned(
              left: (barWidth * normalizedValue - 16).clamp(0.0, barWidth - 40),
              top: 0,
              child: Text(
                '${value.toStringAsFixed(1)}$unit',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Positioned(
              left: barWidth * lowRange - 10,
              top: 30,
              child: Text(
                lowStandard.toString(),
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Positioned(
              left: barWidth * (lowRange + stdRange) - 10,
              top: 30,
              child: Text(
                highStandard.toString(),
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget buildVideoList() {
    if (videoUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: videoUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final url = videoUrls[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayVideoScreen(videoPath: url),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Text(
                    '영상 ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
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
          child: Text(_error!,
              style: const TextStyle(color: Colors.red)),
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
                            builder: (context) => Analysis2Page(
                                analysisId: widget.analysisId)),
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
              buildVideoList(),
              const SizedBox(height: 15),
              Text(
                '반복 횟수: $repetitionCount 회',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '하체 정렬 점수: ${lowerBodyScore.toStringAsFixed(1)} 점',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '총점: ${score.toStringAsFixed(1)} 점',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 팔꿈치 이동 정도
              Row(
                children: [
                  const Text(
                    '팔꿈치 이동 정도 (°)',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 12),
              buildInbodyBar(
                value: palmMove,
                min: 40,
                lowStandard: 60,
                highStandard: 90,
                max: 110,
                unit: '°',
              ),
              const SizedBox(height: 4),
              Text(
                getPalmMoveGuide(palmMove),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 10),

              // 어깨 외전 각도
              Row(
                children: [
                  const Text(
                    '어깨 외전 각도 (°)',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 12),
              buildInbodyBar(
                value: shoulderOuter,
                min: 20,
                lowStandard: 30,
                highStandard: 60,
                max: 70,
                unit: '°',
              ),
              const SizedBox(height: 4),
              Text(
                getShoulderOuterGuide(shoulderOuter),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 10),

              // 팔꿈치 굴곡 각도
              Row(
                children: [
                  const Text(
                    '팔꿈치 굴곡 각도 (°)',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 12),
              buildInbodyBar(
                value: elbowAngle,
                min: 70,
                lowStandard: 90,
                highStandard: 110,
                max: 130,
                unit: '°',
              ),
              const SizedBox(height: 4),
              Text(
                getElbowAngleGuide(elbowAngle),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
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
