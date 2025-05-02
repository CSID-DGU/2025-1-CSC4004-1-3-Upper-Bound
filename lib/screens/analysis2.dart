import 'package:flutter/material.dart';

class Analysis2Page extends StatefulWidget {
  @override
  _Analysis2PageState createState() => _Analysis2PageState();
}

class _Analysis2PageState extends State<Analysis2Page> {
  double neckAngle = 30;
  double shoulderTilt = 10;
  double spineCurve = 5;
  double headShift = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // AppBar 높이를 줄여서 간격을 줄임
        title: Padding(
          padding: const EdgeInsets.only(top: 50), // 텍스트의 상단 padding을 줄임
          child: Text(
            '월요일 오전 운동',
            style: TextStyle(
              fontWeight: FontWeight.w900, // 텍스트를 더 두껍게 설정
              fontSize: 27, // 글자 크기 추가
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 50), // 아이콘의 상단 padding을 줄임
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0), // 제목과 내용 간 간격을 줄임
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // 이전 화면(측면분석)으로 돌아가기
                  },
                  child: Text(
                    '측면분석',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '정면분석',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20), // 슬라이더들 앞 간격
            buildSliderRow('목 기울기 각도 (°)', neckAngle, 0, 90, (value) {
              setState(() {
                neckAngle = value;
              });
            }),
            buildSliderRow('어깨 좌우 기울기 (°)', shoulderTilt, 0, 30, (value) {
              setState(() {
                shoulderTilt = value;
              });
            }, color: Colors.red),
            buildSliderRow('척추 측만 각도 (°)', spineCurve, 0, 45, (value) {
              setState(() {
                spineCurve = value;
              });
            }, color: Colors.red),
            buildSliderRow('머리 중심 이동 거리 (cm)', headShift, 0, 10, (value) {
              setState(() {
                headShift = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget buildSliderRow(String label, double value, double min, double max, Function(double) onChanged, {Color color = Colors.blue}) {
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
      ],
    );
  }
}
