/// 分析記錄資料模型
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisRecord {
  final String id;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final DateTime timestamp;
  final Map<String, dynamic> analysisResults;
  final String deviceInfo;

  AnalysisRecord({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.timestamp,
    required this.analysisResults,
    required this.deviceInfo,
  });

  /// 從 Firestore 文檔轉換為模型
  factory AnalysisRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnalysisRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      analysisResults: data['analysisResults'] ?? {},
      deviceInfo: data['deviceInfo'] ?? '',
    );
  }

  /// 轉換為 Firestore 文檔格式
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'analysisResults': analysisResults,
      'deviceInfo': deviceInfo,
    };
  }

  /// 從 JSON 轉換（用於本地快取）
  factory AnalysisRecord.fromJson(Map<String, dynamic> json) {
    return AnalysisRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      analysisResults: json['analysisResults'] ?? {},
      deviceInfo: json['deviceInfo'] ?? '',
    );
  }

  /// 轉換為 JSON（用於本地快取）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'timestamp': timestamp.toIso8601String(),
      'analysisResults': analysisResults,
      'deviceInfo': deviceInfo,
    };
  }
}
