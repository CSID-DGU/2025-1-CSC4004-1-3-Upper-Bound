import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/pushup_analysis.dart';

Future<PushupAnalysis?> getPushupAnalytics(String analysisId) async {
  final url = Uri.parse('http://43.201.78.241:3000/pushup/analytics?analysisId=$analysisId');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('API 호출 성공: $jsonData');  // 디버깅용 로그
      return PushupAnalysis.fromJson(jsonData);
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('API 호출 오류: $e');
    return null;
  }
}

Future<bool> uploadPushupVideo(String filePath) async {
  final url = Uri.parse('http://43.201.78.241:3000/pushup/upload');
  try {
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('video', filePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      print('영상 업로드 성공');
      return true;
    } else {
      print('영상 업로드 실패: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('영상 업로드 오류: $e');
    return false;
  }
}
