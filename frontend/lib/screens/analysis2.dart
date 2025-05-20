import 'package:flutter/material.dart';

class Analysis2Page extends StatelessWidget {
  const Analysis2Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정면분석 (Analysis2Page)'),
      ),
      body: const Center(
        child: Text(
          '여기는 Analysis2Page입니다.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
