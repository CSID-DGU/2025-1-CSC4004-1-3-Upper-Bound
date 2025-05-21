import 'package:flutter/material.dart';
import 'package:frontend/screens/analysis1.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<dynamic> records = [];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final listUrl =
        Uri.parse('http://43.201.78.241:3000/pushup/analytics?userId=$userId');

    try {
      final response = await http.get(listUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          records = data;
        });
      } else {
        debugPrint('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('요청 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("운동 기록")),
      body: records.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      "점수: ${record['score']} | 반복: ${record['repetition_count']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("날짜: ${record['createdAt']}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Analysis1Page(
                                analysisId: int.parse(record['id']))),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
