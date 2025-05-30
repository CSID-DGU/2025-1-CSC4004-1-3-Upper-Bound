import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../globals/auth_user.dart';

class VideoUploadService {
  static const String uploadUrl = '$urlIp/pushup/upload';

  static Future<int?> uploadVideo(String filePath, String userId) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['userId'] = userId;
      request.files.add(await http.MultipartFile.fromPath('video', filePath));

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);

        final idStr = json['analysisId'];
        final analysisId = int.tryParse(idStr.toString());

        print('업로드 성공: analysisId = $analysisId');
        return analysisId;
      } else {
        print('업로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
      return null;
    }
  }
}
