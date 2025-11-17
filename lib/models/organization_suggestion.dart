/// 收納建議模型
class OrganizationSuggestion {
  final String suggestionId;
  final String analysisId;
  final int priority;
  final String title;
  final String description;
  final List<String> steps;
  final String estimatedTime;
  final List<RecommendedProduct> recommendedProducts;
  final String? beforeAfterImpact;
  final DateTime createdAt;

  OrganizationSuggestion({
    required this.suggestionId,
    required this.analysisId,
    required this.priority,
    required this.title,
    required this.description,
    required this.steps,
    required this.estimatedTime,
    required this.recommendedProducts,
    this.beforeAfterImpact,
    required this.createdAt,
  });

  factory OrganizationSuggestion.fromJson(Map<String, dynamic> json) {
    return OrganizationSuggestion(
      suggestionId: json['suggestion_id'],
      analysisId: json['analysis_id'],
      priority: json['priority'],
      title: json['title'],
      description: json['description'],
      steps: List<String>.from(json['steps']),
      estimatedTime: json['estimated_time'],
      recommendedProducts: (json['recommended_products'] as List)
          .map((product) => RecommendedProduct.fromJson(product))
          .toList(),
      beforeAfterImpact: json['before_after_impact'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'suggestion_id': suggestionId,
    'analysis_id': analysisId,
    'priority': priority,
    'title': title,
    'description': description,
    'steps': steps,
    'estimated_time': estimatedTime,
    'recommended_products': recommendedProducts.map((p) => p.toJson()).toList(),
    'before_after_impact': beforeAfterImpact,
    'created_at': createdAt.toIso8601String(),
  };
}

class RecommendedProduct {
  final String name;
  final String? url;
  final double? price;
  final String? imageUrl;

  RecommendedProduct({
    required this.name,
    this.url,
    this.price,
    this.imageUrl,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      name: json['name'],
      url: json['url'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'price': price,
    'image_url': imageUrl,
  };
}
