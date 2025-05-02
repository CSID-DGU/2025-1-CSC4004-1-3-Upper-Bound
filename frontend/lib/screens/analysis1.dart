import 'package:flutter/material.dart';
import 'analysis2.dart'; // Analysis2Page import 추가

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MovementAnalysisPage(),
    );
  }
}

class MovementAnalysisPage extends StatefulWidget {
  @override
  _MovementAnalysisPageState createState() => _MovementAnalysisPageState();
}

class _MovementAnalysisPageState extends State<MovementAnalysisPage> {
  double palmMovement = 100;
  double shoulderExternalAngle = 3;
  double shoulderInternalAngle = 90;
  double palmWristAngle = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, // AppBar 높이를 충분히 크게 설정
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
                    // '측면분석'을 클릭하면 Analysis2Page로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Analysis2Page()),
                    );
                  },
                  child: Text(
                    '측면분석',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // '정면분석'을 클릭하면 Analysis2Page로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Analysis2Page()),
                    );
                  },
                  child: Text(
                    '정면분석',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30), // 슬라이더들 앞 간격
            buildSliderRow('팔꿈치 이동 정도 (cm)', palmMovement, 0, 150, (value) {
              setState(() {
                palmMovement = value;
              });
            }),
            buildSliderRow('어깨 외전 각도 (°)', shoulderExternalAngle, 0, 5, (value) {
              setState(() {
                shoulderExternalAngle = value;
              });
            }, color: Colors.red),
            buildSliderRow('어깨 내전 각도 (°)', shoulderInternalAngle, 0, 180, (value) {
              setState(() {
                shoulderInternalAngle = value;
              });
            }, color: Colors.red),
            buildSliderRow('팔꿈치 굴곡 범위의 차 (°)', palmWristAngle, 0, 5, (value) {
              setState(() {
                palmWristAngle = value;
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
