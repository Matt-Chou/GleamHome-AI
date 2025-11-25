/// Cloud Firestore 資料庫服務
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/analysis_record.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 取得使用者的分析記錄子集合參考
  CollectionReference _getUserAnalysisRecordsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('analysisRecords');
  }

  /// 新增分析記錄
  /// 
  /// 回傳新建立的記錄 ID
  Future<String> addAnalysisRecord(AnalysisRecord record) async {
    try {
      debugPrint('📝 新增分析記錄...');
      final recordsCollection = _getUserAnalysisRecordsCollection(record.userId);
      final docRef = await recordsCollection.add(record.toFirestore());
      debugPrint('✅ 記錄已儲存: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ 新增記錄失敗: $e');
      rethrow;
    }
  }

  /// 取得單一分析記錄
  Future<AnalysisRecord?> getAnalysisRecord(String userId, String recordId) async {
    try {
      final recordsCollection = _getUserAnalysisRecordsCollection(userId);
      final doc = await recordsCollection.doc(recordId).get();
      if (doc.exists) {
        return AnalysisRecord.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ 取得記錄失敗: $e');
      return null;
    }
  }

  /// 取得使用者的所有分析記錄（即時串流）
  /// 
  /// [userId] - 使用者 ID
  /// [limit] - 限制數量（可選）
  Stream<List<AnalysisRecord>> getUserRecordsStream(String userId, {int? limit}) {
    final recordsCollection = _getUserAnalysisRecordsCollection(userId);
    Query query = recordsCollection.orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AnalysisRecord.fromFirestore(doc))
          .toList();
    });
  }

  /// 取得使用者的所有分析記錄（一次性查詢）
  Future<List<AnalysisRecord>> getUserRecords(String userId, {int? limit}) async {
    try {
      final recordsCollection = _getUserAnalysisRecordsCollection(userId);
      Query query = recordsCollection.orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AnalysisRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ 查詢記錄失敗: $e');
      return [];
    }
  }

  /// 更新分析記錄
  Future<void> updateAnalysisRecord(String userId, String recordId, Map<String, dynamic> data) async {
    try {
      final recordsCollection = _getUserAnalysisRecordsCollection(userId);
      await recordsCollection.doc(recordId).update(data);
      debugPrint('✅ 記錄已更新: $recordId');
    } catch (e) {
      debugPrint('❌ 更新記錄失敗: $e');
      rethrow;
    }
  }

  /// 刪除分析記錄
  Future<void> deleteAnalysisRecord(String userId, String recordId) async {
    try {
      final recordsCollection = _getUserAnalysisRecordsCollection(userId);
      await recordsCollection.doc(recordId).delete();
      debugPrint('🗑️ 記錄已刪除: $recordId');
    } catch (e) {
      debugPrint('❌ 刪除記錄失敗: $e');
      rethrow;
    }
  }

  /// 批次刪除使用者的所有記錄
  Future<void> deleteAllUserRecords(String userId) async {
    try {
      final recordsCollection = _getUserAnalysisRecordsCollection(userId);
      final snapshot = await recordsCollection.get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('🗑️ 已刪除 ${snapshot.docs.length} 筆記錄');
    } catch (e) {
      debugPrint('❌ 批次刪除失敗: $e');
      rethrow;
    }
  }

  /// 取得記錄總數
  Future<int> getUserRecordCount(String userId) async {
    try {
      final recordsCollection = _getUserAnalysisRecordsCollection(userId);
      final snapshot = await recordsCollection
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ 取得計數失敗: $e');
      return 0;
    }
  }
}
