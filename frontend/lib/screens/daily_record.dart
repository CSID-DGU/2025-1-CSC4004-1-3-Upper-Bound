import 'package:flutter/material.dart';

class DailyRecordPage extends StatelessWidget {
  final int day; // 클릭한 날짜
  final int year; // 선택한 연도
  final int month; // 선택한 월

  const DailyRecordPage({Key? key, required this.day, required this.year, required this.month}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String recordDate = '$year년 $month월 $day일'; // 선택한 날짜를 문자열로 표시

    return Scaffold(
      appBar: AppBar(
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
              '운동 기록: $recordDate', // 선택한 날짜를 표시
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _InfoRow(icon: '🔥', title: '칼로리 소모', description: '1234KCAL'),
            const SizedBox(height: 20),
            _InfoRow(icon: '🖇️', title: '세트 구성', description: '3세트 * 15회'),
            const SizedBox(height: 20),
            _InfoRow(icon: '⏰', title: '소요 시간', description: '6분'),
            const SizedBox(height: 20),
            _InfoRow(icon: '✅', title: '자세 정확도', description: '70%'),
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
