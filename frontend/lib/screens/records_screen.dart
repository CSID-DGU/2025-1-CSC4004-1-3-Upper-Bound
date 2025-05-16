import 'package:flutter/material.dart';
import 'daily_record.dart'; // DailyRecordPage를 import

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  int selectedYear = DateTime.now().year; // 현재 연도
  int selectedMonth = DateTime.now().month; // 현재 월

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          // 이전 월로 이동하는 버튼
          IconButton(
            icon: Icon(Icons.arrow_left),
            onPressed: () {
              setState(() {
                // 이전 월로 이동
                if (selectedMonth == 1) {
                  selectedMonth = 12;
                  selectedYear--;
                } else {
                  selectedMonth--;
                }
              });
            },
          ),

          // 날짜 표시
          Text(
            '$selectedYear년 ${selectedMonth}월',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          // 다음 월로 이동하는 버튼
          IconButton(
            icon: Icon(Icons.arrow_right),
            onPressed: () {
              setState(() {
                // 다음 월로 이동
                if (selectedMonth == 12) {
                  selectedMonth = 1;
                  selectedYear++;
                } else {
                  selectedMonth++;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            calendarWidget(), // 달력을 그리는 함수 호출
          ],
        ),
      ),
    );
  }

  // 달력을 그리는 함수
  Widget calendarWidget() {
    final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final int totalDays = DateTime(selectedYear, selectedMonth + 1, 0).day; // 해당 월의 마지막 날

    DateTime firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    int firstDayWeekday = firstDayOfMonth.weekday; // 첫 번째 날의 요일

    // DateTime.weekday의 결과는 1 (월요일)부터 7 (일요일)까지 나온다.
    // 일요일을 0으로 바꾸기 위해 수정
    firstDayWeekday = (firstDayWeekday == 7) ? 0 : firstDayWeekday;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days
                .map((d) => Text(
              d,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ))
                .toList(),
          ),
          const SizedBox(height: 10),
          // 달력의 각 날짜를 Row로 배치
          ...List.generate(6, (week) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                int dayNum = week * 7 + dayIndex - firstDayWeekday + 1;
                if (dayNum <= 0 || dayNum > totalDays) return const SizedBox(width: 40);

                // 날짜 클릭 시 `DailyRecordPage`로 이동
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyRecordPage(day: dayNum, year: selectedYear, month: selectedMonth),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}
