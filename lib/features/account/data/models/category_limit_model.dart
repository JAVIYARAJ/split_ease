import '../../domain/entities/category_limit_entity.dart';

class CategoryLimitModel extends CategoryLimitEntity {
  const CategoryLimitModel({
    required super.id,
    required super.icon,
    required super.name,
    required super.color,
    super.limitAmount,
    super.lastUpdated,
  });

  factory CategoryLimitModel.fromJson(Map<String, dynamic> json) {
    return CategoryLimitModel(
      id: json['id'] ?? '',
      icon: json['icon'] ?? 'category',
      name: json['name'] ?? 'Unknown',
      color: json['color'] ?? '#000000',
      limitAmount: json['limit_amount'] != null ? (json['limit_amount'] as num).toDouble() : null,
      lastUpdated: json['last_updated'],
    );
  }
}
