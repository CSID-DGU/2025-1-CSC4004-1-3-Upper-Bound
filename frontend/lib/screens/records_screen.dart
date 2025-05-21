import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analysis1.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<String> records = ['운동기록 1'];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecords = prefs.getStringList('records');
    if (savedRecords != null && savedRecords.isNotEmpty) {
      setState(() {
        records = savedRecords;
      });
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('records', records);
  }

  Future<void> _editRecordDialog(int index) async {
    final controller = TextEditingController(text: records[index]);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 이름 수정'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '새 이름을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        records[index] = result.trim();
      });
      await _saveRecords(); // 저장
    }
  }

  void _addNewRecord() {
    setState(() {
      records.add('운동기록 ${records.length + 1}');
    });
    _saveRecords(); // 저장
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final title = records[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editRecordDialog(index),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Analysis1Page()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
