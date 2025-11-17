/// 用戶模型
class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? provider; // google, facebook, apple
  final SubscriptionTier subscriptionTier;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.provider,
    this.subscriptionTier = SubscriptionTier.free,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photo_url'],
      provider: json['provider'],
      subscriptionTier: _parseSubscriptionTier(json['subscription_tier']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': id,
    'email': email,
    'name': name,
    'photo_url': photoUrl,
    'provider': provider,
    'subscription_tier': subscriptionTier.name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? provider,
    SubscriptionTier? subscriptionTier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum SubscriptionTier { free, premium }

SubscriptionTier _parseSubscriptionTier(String? value) {
  return value == 'premium' ? SubscriptionTier.premium : SubscriptionTier.free;
}
