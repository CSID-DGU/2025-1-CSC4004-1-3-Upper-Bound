import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';  // video_player 패키지 추가

import 'analysis2.dart'; // Analysis2Page를 가져옵니다
import 'home_screen.dart'; // HomePage 추가
import 'profile_screen.dart'; // ProfilePage 추가
import 'main_screen.dart'; // MainPage 추가

class Analysis1Page extends StatefulWidget {
  @override
  _Analysis1PageState createState() => _Analysis1PageState();
}

class _Analysis1PageState extends State<Analysis1Page> {
  int _currentIndex = 0; // 탭 인덱스

  // 비디오 관련 변수
  VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;

  // 각 슬라이더의 초기값
  double palmMove = 95;
  double shoulderOuter = 3;
  double shoulderInner = 75;
  double elbowAngle = 1;

  @override
  @override
  void initState() {
    super.initState();
    // 비디오 초기화
    _controller = VideoPlayerController.asset('assets/video.mp4')  // 비디오 경로 설정
      ..initialize().then((_) {
        // 비디오 초기화가 끝나면 화면 갱신
        setState(() {
          // Video has been initialized
        });
      }).catchError((error) {
        print("Error initializing video: $error");  // 에러 발생 시 출력
      });
  }


  @override
  void dispose() {
    super.dispose();
    _controller?.dispose(); // 비디오 컨트롤러 종료
  }

  final List<Widget> _screens = [
    HomeScreen(), // 홈 화면
    MainScreen(), // 메인 화면
    ProfileScreen(), // 내정보 화면
    Analysis1Page(), // 분석 화면
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 비디오 표시
            _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
                : Center(child: CircularProgressIndicator()),  // 비디오가 초기화되기 전에는 로딩 표시
            SizedBox(height: 10),
            // 슬라이더들 앞에 텍스트
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // 측면분석 클릭 시 현재 화면(Analysis1Page)
                    setState(() {
                      _currentIndex = 3; // 현재 분석 화면으로 이동
                    });
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
                    // 정면분석 클릭 시 Analysis2Page로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Analysis2Page()),
                    );
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // 현재 탭을 반영
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 탭을 누를 때마다 _currentIndex를 업데이트
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
          activeColor: color, // 활성화된 슬라이더 색상
          inactiveColor: Colors.grey[300], // 비활성화된 슬라이더 색상
        ),
        Text('${value.toStringAsFixed(1)}°', style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
