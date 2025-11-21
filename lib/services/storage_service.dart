/// Firebase Storage 影像儲存服務
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 上傳影像到 Firebase Storage
  /// 
  /// [file] - 要上傳的影像檔案
  /// [userId] - 使用者 ID
  /// [fileName] - 檔案名稱（可選，預設使用時間戳記）
  /// 
  /// 回傳上傳後的檔案 URL
  Future<String> uploadImage(File file, String userId, {String? fileName}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'image_$timestamp.jpg';
      final path = 'users/$userId/images/$name';

      debugPrint('📤 開始上傳影像: $path');

      // 建立參考並上傳
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // 監聽上傳進度
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes * 100;
        debugPrint('📊 上傳進度: ${progress.toStringAsFixed(1)}%');
      });

      // 等待上傳完成
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ 上傳成功: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ 上傳失敗: $e');
      rethrow;
    }
  }

  /// 上傳縮圖（較小尺寸）
  Future<String> uploadThumbnail(File file, String userId, {String? fileName}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = fileName ?? 'thumb_$timestamp.jpg';
    final path = 'users/$userId/thumbnails/$name';

    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// 刪除影像
  Future<void> deleteImage(String imageUrl) async {
    try {
      debugPrint('🗑️ 準備刪除影像: $imageUrl');
      
      // 從 URL 取得 Storage 參考
      final ref = _storage.refFromURL(imageUrl);
      debugPrint('📍 檔案路徑: ${ref.fullPath}');
      
      // 執行刪除
      await ref.delete();
      debugPrint('✅ 刪除影像成功: ${ref.fullPath}');
    } catch (e) {
      debugPrint('❌ 刪除影像失敗: $e');
      debugPrint('影像 URL: $imageUrl');
      rethrow;
    }
  }

  /// 取得影像參考
  Reference getImageRef(String path) {
    return _storage.ref().child(path);
  }

  /// 列出使用者所有影像
  Future<List<String>> listUserImages(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/images');
      final result = await ref.listAll();
      
      final urls = await Future.wait(
        result.items.map((item) => item.getDownloadURL()),
      );
      
      return urls;
    } catch (e) {
      debugPrint('❌ 列出影像失敗: $e');
      return [];
    }
  }
}
