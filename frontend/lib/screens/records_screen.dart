import 'package:flutter/material.dart';
import 'analysis1.dart'; // Analysis1Page import

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  // 운동 기록 개수 예시 (실제론 DB/API 연동 가능)
  final int recordCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('운동 기록'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recordCount,
        itemBuilder: (context, index) {
          final recordNum = index + 1;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text('운동기록 $recordNum', style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Analysis1Page()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
