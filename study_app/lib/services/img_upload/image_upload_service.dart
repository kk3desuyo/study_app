// services/image_upload_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

class ImageUploadService {
  final String uploadUrl =
      'https://us-central1-study-app-6a883.cloudfunctions.net/cloudinary_function';

  /// 画像を圧縮し、Base64エンコードしてアップロードする関数
  /// 成功すると画像のURLを返し、失敗すると例外を投げます。
  Future<String> uploadImage(File imageFile, String type) async {
    try {
      // 画像を圧縮
      final compressedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 800,
        minHeight: 600,
        quality: 70, // 圧縮品質を調整
      );

      if (compressedImage == null) {
        throw Exception('画像の圧縮に失敗しました。');
      }

      // Base64エンコード
      String base64Image =
          'data:image/jpeg;base64,' + base64Encode(compressedImage);

      // Firebase FunctionsのエンドポイントにPOSTリクエストを送信
      final response = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['url'] != null) {
          return responseData['url'];
        } else {
          throw Exception('レスポンスに画像URLが含まれていません。');
        }
      } else {
        throw Exception('画像のアップロードに失敗しました。ステータスコード: ${response.statusCode}');
      }
    } catch (e) {
      print('画像アップロードエラー: $e');
      throw Exception('画像のアップロード中にエラーが発生しました。');
    }
  }
}
