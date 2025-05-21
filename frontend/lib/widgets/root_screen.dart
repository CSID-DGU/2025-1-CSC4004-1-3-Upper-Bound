import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/records_screen.dart';
import '../screens/profile_screen.dart';

class RootScreen extends StatefulWidget {
  final CameraDescription camera;

  const RootScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      MainScreen(camera: widget.camera),
      RecordsScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: '메인 기능'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '운동 기록'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
      ),
    );
  }
}