// services/image_upload_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  /// 画像を圧縮し、Firebase Storageにアップロードする関数
  /// 成功すると画像のURLを返し、失敗すると例外を投げます。
  Future<String> uploadImage(File imageFile, String type) async {
    try {
      // 画像を圧縮
      final compressedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 800,
        minHeight: 600,
        quality: 1, // 圧縮品質を調整
      );
      print('Compressed image size: ${compressedImage!.length} bytes');
      if (compressedImage == null) {
        throw Exception('画像の圧縮に失敗しました。');
      }

      // 圧縮した画像を一時ファイルとして保存
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(compressedImage);

      // Firebase Storageの参照を取得
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');

      // アップロードタスクを開始
      UploadTask uploadTask = storageRef.putFile(tempFile);

      // アップロードの完了を待つ
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // ダウンロードURLを取得
      String downloadURL = await snapshot.ref.getDownloadURL();

      print('Upload successful. Download URL: $downloadURL');

      // 一時ファイルを削除
      await tempFile.delete();

      return downloadURL;
    } catch (e) {
      print('画像アップロードエラー: $e');
      throw Exception('画像のアップロード中にエラーが発生しました。');
    }
  }
}
