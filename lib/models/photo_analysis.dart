/// 照片分析結果模型
class PhotoAnalysis {
  final String analysisId;
  final String userId;
  final String imageUrl;
  final String roomType;
  final double cleanlinessScore; // 0-10
  final List<IdentifiedObject> identifiedObjects;
  final List<String> mainIssues;
  final double spaceUtilization; // 0-1
  final String analysisDetails;
  final int tokensConsumed;
  final DateTime createdAt;

  PhotoAnalysis({
    required this.analysisId,
    required this.userId,
    required this.imageUrl,
    required this.roomType,
    required this.cleanlinessScore,
    required this.identifiedObjects,
    required this.mainIssues,
    required this.spaceUtilization,
    required this.analysisDetails,
    required this.tokensConsumed,
    required this.createdAt,
  });

  factory PhotoAnalysis.fromJson(Map<String, dynamic> json) {
    return PhotoAnalysis(
      analysisId: json['analysis_id'],
      userId: json['user_id'],
      imageUrl: json['image_url'],
      roomType: json['room_type'],
      cleanlinessScore: (json['cleanliness_score'] as num).toDouble(),
      identifiedObjects: (json['identified_objects'] as List)
          .map((obj) => IdentifiedObject.fromJson(obj))
          .toList(),
      mainIssues: List<String>.from(json['main_issues']),
      spaceUtilization: (json['space_utilization'] as num).toDouble(),
      analysisDetails: json['analysis_details'],
      tokensConsumed: json['tokens_consumed'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'analysis_id': analysisId,
    'user_id': userId,
    'image_url': imageUrl,
    'room_type': roomType,
    'cleanliness_score': cleanlinessScore,
    'identified_objects': identifiedObjects.map((obj) => obj.toJson()).toList(),
    'main_issues': mainIssues,
    'space_utilization': spaceUtilization,
    'analysis_details': analysisDetails,
    'tokens_consumed': tokensConsumed,
    'created_at': createdAt.toIso8601String(),
  };
}

class IdentifiedObject {
  final String name;
  final int count;
  final String location;

  IdentifiedObject({
    required this.name,
    required this.count,
    required this.location,
  });

  factory IdentifiedObject.fromJson(Map<String, dynamic> json) {
    return IdentifiedObject(
      name: json['name'],
      count: json['count'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'count': count,
    'location': location,
  };
}
