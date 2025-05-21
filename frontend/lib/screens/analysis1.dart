import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'analysis2.dart';

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

  bool _isLoading = true;
  String? _rawJson;
  String? _summaryJson;
  String? _error;

  String? userId;

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

  Widget buildFixedColorSliderRow(String label, double value, double min, double max, {Color color = Colors.blue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label : ${value.toStringAsFixed(1)}'),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
          ),
          child: IgnorePointer(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (v) {},
            ),
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
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 기존 코드 중 build 메서드 안쪽 Row 부분만 교체
              Row(
                crossAxisAlignment: CrossAxisAlignment.end, // 높이 맞춤
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
              const SizedBox(height: 10),
              buildFixedColorSliderRow('팔꿈치 이동 정도(cm)', palmMove, 90, 110),
              buildFixedColorSliderRow('어깨 외전 각도(°)', shoulderOuter, -100, 100, color: Colors.blue),
              buildFixedColorSliderRow('팔꿈치 굴곡 범위의 차(°)', elbowAngle, 0, 110),
              buildFixedColorSliderRow('하체 정렬 점수(점)', lowerBodyScore, 0, 100, color: Colors.blue),
              const SizedBox(height: 30),
              // const Text('■ API 응답 전체 JSON', style: TextStyle(fontWeight: FontWeight.bold)),
              // Text(_rawJson ?? '없음', style: const TextStyle(fontSize: 12)),
              // const SizedBox(height: 20),
              // const Text('■ summary JSON', style: TextStyle(fontWeight: FontWeight.bold)),
              // Text(_summaryJson ?? '없음', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
