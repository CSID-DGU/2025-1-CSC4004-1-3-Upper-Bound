import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:video_compress/video_compress.dart';
import '../globals/auth_user.dart';

class VideoUploadService {
  static const String uploadUrl = '$urlIp/pushup/upload';

  static Future<int?> uploadVideo(String filePath, String userId) async {
    try {
      // 압축 전 파일 크기
      final originalFile = File(filePath);
      final originalSize = await originalFile.length();
      print('압축 전 파일 크기: ${(originalSize / (1024 * 1024)).toStringAsFixed(2)} MB');

      // 비디오 압축
      final info = await VideoCompress.compressVideo(
        filePath,
        quality: VideoQuality.LowQuality,
        deleteOrigin: true,
      );

      if (info == null || info.file == null) {
        print('비디오 압축 실패');
        return null;
      }

      final compressedFile = info.file!;
      final compressedSize = await compressedFile.length();
      print('압축 후 파일 크기: ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB');
      print('압축된 파일 경로: ${compressedFile.path}');

      // 업로드 요청
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['userId'] = userId;
      request.files.add(await http.MultipartFile.fromPath('video', compressedFile.path));

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
    } finally {
      VideoCompress.dispose();
    }
  }
}
