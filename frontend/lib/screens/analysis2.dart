import 'package:flutter/material.dart';
import 'analysis1.dart'; // Analysis1Page를 import 추가

class Analysis2Page extends StatefulWidget {
  @override
  _Analysis2PageState createState() => _Analysis2PageState();
}

class _Analysis2PageState extends State<Analysis2Page> {
  int _currentIndex = 0; // 탭 인덱스

  // 각 슬라이더의 초기값
  double wristFlexion = 95;
  double wristPosition = 3;
  double palmMove = 70;

  final List<Widget> _screens = [
    // 홈, 메인, 내 정보 등 다른 페이지들을 추가할 수 있음.
    Center(child: Text('홈 화면')),
    Center(child: Text('메인 화면')),
    Center(child: Text('내정보 화면')),
    Analysis2Page(), // 분석 화면
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // AppBar 높이를 줄여서 간격을 줄임
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: SizedBox.shrink(), // '정면분석' 큰 글씨를 지움
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 슬라이더들 앞에 텍스트
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Analysis1Page()), // Analysis1Page로 이동
                    );
                  },
                  child: Text(
                    '측면분석',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                  child: Text(
                    '정면분석',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            buildSliderRow('손목 굴곡 범위(°)', wristFlexion, 90, 110, (value) {
              setState(() {
                wristFlexion = value;
              });
            }),
            buildSliderRow('손목 위치(°)', wristPosition, 0, 5, (value) {
              setState(() {
                wristPosition = value;
              });
            }, color: Colors.red),
            buildSliderRow('팔꿈치 이동 범위(°)', palmMove, 60, 90, (value) {
              setState(() {
                palmMove = value;
              });
            }, color: Colors.red),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, color: Colors.black),
            label: '메인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: '내정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics, color: Colors.black),
            label: '분석',
          ),
        ],
      ),
    );
  }

  // 슬라이더를 구성하는 위젯
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
          activeColor: color,  // 활성화된 슬라이더 색상
          inactiveColor: Colors.grey[300],  // 비활성화된 슬라이더 색상
        ),
        Text('${value.toStringAsFixed(1)}°', style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
