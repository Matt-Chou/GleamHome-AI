/// AI 對話歷史模型
class AIConversation {
  final String conversationId;
  final String analysisId;
  final String userId;
  final List<Message> messages;
  final int totalTokensUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AIConversation({
    required this.conversationId,
    required this.analysisId,
    required this.userId,
    required this.messages,
    required this.totalTokensUsed,
    required this.createdAt,
    this.updatedAt,
  });

  factory AIConversation.fromJson(Map<String, dynamic> json) {
    return AIConversation(
      conversationId: json['conversation_id'],
      analysisId: json['analysis_id'],
      userId: json['user_id'],
      messages: (json['messages'] as List)
          .map((msg) => Message.fromJson(msg))
          .toList(),
      totalTokensUsed: json['total_tokens_used'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'conversation_id': conversationId,
    'analysis_id': analysisId,
    'user_id': userId,
    'messages': messages.map((msg) => msg.toJson()).toList(),
    'total_tokens_used': totalTokensUsed,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final int tokensUsed;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.tokensUsed,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      role: json['role'],
      content: json['content'],
      tokensUsed: json['tokens_used'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'tokens_used': tokensUsed,
    'timestamp': timestamp.toIso8601String(),
  };
}
