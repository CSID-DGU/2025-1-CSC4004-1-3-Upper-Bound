import 'package:flutter/material.dart';

class DailyRecordPage extends StatelessWidget {
  final String recordName; // 기록 이름을 받음

  const DailyRecordPage({Key? key, required this.recordName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recordName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운동 기록: $recordName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _InfoRow(icon: '🔥', title: '팔꿈치-손목 정렬', description: '1234KCAL'),
            const SizedBox(height: 20),
            _InfoRow(icon: '🖇️', title: '어깨 외전/내전 각도', description: '3세트 * 15회'),
            const SizedBox(height: 20),
            _InfoRow(icon: '⏰', title: '팔꿈치 가동범위', description: '6분'),
            const SizedBox(height: 20),
            _InfoRow(icon: '✅', title: '하체 정렬', description: '70%'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 30),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
