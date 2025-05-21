import 'dart:io';
import 'package:http/http.dart' as http;

class VideoUploadService {
  static const String uploadUrl = 'http://43.201.78.241:3000/pushup/upload';

  static Future<bool> uploadVideo(String filePath, String userId) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['userId'] = userId;
      request.files.add(
        await http.MultipartFile.fromPath('video', filePath),
      );

      final response = await request.send();

      if (response.statusCode == 201) {
        print('업로드 성공');
        return true;
      } else {
        print('업로드 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
      return false;
    }
  }
}