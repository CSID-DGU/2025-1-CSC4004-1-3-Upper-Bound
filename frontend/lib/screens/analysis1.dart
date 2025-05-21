import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'analysis2.dart';
import 'display_video_screen.dart'; // 영상 재생 화면 import

class Analysis1Page extends StatefulWidget {
  const Analysis1Page({Key? key}) : super(key: key);

  @override
  State<Analysis1Page> createState() => _Analysis1PageState();
}

class _Analysis1PageState extends State<Analysis1Page> {
  double palmMove = 95;
  double shoulderOuter = 3;
  double elbowAngle = 1;
  double lowerBodyScore = 0;

  int repetitionCount = 0;  // 반복 횟수
  double score = 0.0;        // 총점

  bool _isLoading = true;
  String? _rawJson;
  String? _summaryJson;
  String? _error;

  String? userId;

  // 영상 URL 리스트 (예시)
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
      final listUrl = Uri.parse('http://43.201.78.241:3000/pushup/analytics?userId=$userId');
      final listResponse = await http.get(listUrl);

      if (listResponse.statusCode == 200) {
        final listData = jsonDecode(listResponse.body);

        if (listData is List && listData.isNotEmpty) {
          final latestAnalysis = listData.last;
          final analysisId = latestAnalysis['id'];

          final detailUrl = Uri.parse('http://43.201.78.241:3000/pushup/analytics?analysisId=$analysisId');
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
            final summary = (summaryRaw is String) ? jsonDecode(summaryRaw) : summaryRaw;

            setState(() {
              _rawJson = jsonEncode(detailData);
              _summaryJson = jsonEncode(summary);

              palmMove = (summary['elbow_motion'] as num?)?.toDouble() ?? 0.0;
              shoulderOuter = (summary['shoulder_abduction'] as num?)?.toDouble() ?? 0.0;
              elbowAngle = (summary['elbow_flexion'] as num?)?.toDouble() ?? 0.0;
              lowerBodyScore = (summary['lower_body_alignment_score'] as num?)?.toDouble() ?? 0.0;

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
        } else {
          setState(() {
            _error = '분석 데이터 리스트가 비어있습니다.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = '리스트 API 에러: ${listResponse.statusCode}';
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

  // 상세 해석 가이드 함수들
  String getPalmMoveGuide(double value) {
    if (value < 90) {
      return '팔꿈치를 몸에서 좀 더 벌려 공간을 확보하세요.';
    } else if (value > 110) {
      return '팔꿈치를 몸 쪽으로 살짝 모아 긴장을 줄이세요.';
    } else {
      return '팔꿈치 이동 범위가 적절합니다.';
    }
  }

  String getShoulderOuterGuide(double value) {
    if (value < 0) {
      return '팔을 몸 옆으로 곧게 들어 올려 주세요.';
    } else if (value > 150) {
      return '팔을 들어 올릴 때 어깨가 과도하게 올라가지 않도록 조절하세요.';
    } else {
      return '어깨 외전 각도가 적절합니다.';
    }
  }

  String getElbowAngleGuide(double value) {
    if (value < 20) {
      return '팔꿈치를 더 깊게 굽혀 가슴 쪽으로 당기세요.';
    } else if (value > 40) {
      return '팔꿈치 굴곡 각도를 적절히 조절하세요.';
    } else {
      return '팔꿈치 굴곡 범위가 적절합니다.';
    }
  }


  Widget buildVideoList() {
    if (videoUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          '촬영 영상',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
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

  Widget buildIndicatorCard({
    required String title,
    required double value,
    required String normalRange,
    required String guide,
    required bool isNormal,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isNormal ? Icons.check_circle : Icons.warning,
              color: isNormal ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$title: ${value.toStringAsFixed(1)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('정상 범위: $normalRange',
                      style:
                      TextStyle(color: Colors.grey[600], fontSize: 13)),
                  Text(guide,
                      style:
                      TextStyle(color: Colors.grey[800], fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
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
            child: Text(_error!, style: const TextStyle(color: Colors.red)))
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
                        MaterialPageRoute(builder: (context) => const Analysis2Page()),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),


              Text(
                '총점: ${score.toStringAsFixed(1)} 점',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              buildIndicatorCard(
                title: '팔꿈치 이동 정도(cm)',
                value: palmMove,
                normalRange: '90 ~ 110',
                guide: getPalmMoveGuide(palmMove),
                isNormal: palmMove >= 90 && palmMove <= 110,
              ),
              buildIndicatorCard(
                title: '어깨 외전 각도(°)',
                value: shoulderOuter,
                normalRange: '0 ~ 150 (음수는 측정 방식 차이)',
                guide: getShoulderOuterGuide(shoulderOuter),
                isNormal: shoulderOuter >= 0 && shoulderOuter <= 150,
              ),
              buildIndicatorCard(
                title: '팔꿈치 굴곡 범위의 차(°)',
                value: elbowAngle,
                normalRange: '20 ~ 40',
                guide: getElbowAngleGuide(elbowAngle),
                isNormal: elbowAngle >= 20 && elbowAngle <= 40,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
