import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'analysis1.dart';

class RecordsScreen extends StatelessWidget {
  final CameraDescription? camera;

  const RecordsScreen({Key? key, this.camera}) : super(key: key);

  static const List<String> records = [
    '운동기록1',
    '운동기록2',
    '운동기록3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 기록 목록')),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(records[index]),
            onTap: () {
              if (records[index] == '운동기록1') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Analysis1Page(camera: camera),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${records[index]} 선택됨')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
