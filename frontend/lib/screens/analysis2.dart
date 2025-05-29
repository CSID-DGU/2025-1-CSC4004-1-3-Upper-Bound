import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

import 'analysis1.dart';

class Analysis2Page extends StatefulWidget {
  final int analysisId;
  const Analysis2Page({super.key, required this.analysisId});

  @override
  _Analysis2PageState createState() => _Analysis2PageState();
}

class _Analysis2PageState extends State<Analysis2Page> {
  late List<double> elbowY = [];
  late List<double> elbowFlexion = [];
  late List<double> lowerBodyAngle = [];
  bool isLoading = true;

  final double fps = 1.0; // fps를 1로 낮춤 (초당 1 프레임)

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://43.201.78.241:3000/pushup/analytics?analysisId=${widget.analysisId}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('data length: ${data['timeseries']['elbow_y'].length}, fps: $fps');
      setState(() {
        elbowY = List<double>.from(data['timeseries']['elbow_y']);
        elbowFlexion = List<double>.from(data['timeseries']['elbow_flexion']);
        lowerBodyAngle =
        List<double>.from(data['timeseries']['lower_body_angle']);
        isLoading = false;
      });
    } else {
      throw Exception('데이터 로드 실패');
    }
  }

  Widget _buildLineChart(List<double> data, Color color) {
    const margin = 5.0;
    double minY = data.reduce((a, b) => a < b ? a : b) - margin;
    double maxY = data.reduce((a, b) => a > b ? a : b) + margin;
    if (minY > maxY) {
      final temp = minY;
      minY = maxY;
      maxY = temp;
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: data.length.toDouble(), // fps 나누기 제거, 인덱스 그대로 사용
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value)) // fps 나누기 제거
                .toList(),
            isCurved: true,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Analysis1Page(
                              analysisId: widget.analysisId,
                            )),
                      );
                    },
                    child: const Text(
                      '측면분석',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '분석그래프',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('팔꿈치 상하 움직임',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(height: 300, child: _buildLineChart(elbowY, Colors.blue)),
              const SizedBox(height: 20),
              const Text('팔꿈치 굽힘 각도',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(height: 300, child: _buildLineChart(elbowFlexion, Colors.green)),
              const SizedBox(height: 20),
              const Text('하체 각도',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(height: 300, child: _buildLineChart(lowerBodyAngle, Colors.orange)),
            ],
          ),
        ),
      ),
    );
  }
}
