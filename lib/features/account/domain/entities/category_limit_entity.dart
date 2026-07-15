import 'package:equatable/equatable.dart';

class CategoryLimitEntity extends Equatable {
  final String id;
  final String icon;
  final String name;
  final String color;
  final double? limitAmount;
  final String? lastUpdated;

  const CategoryLimitEntity({
    required this.id,
    required this.icon,
    required this.name,
    required this.color,
    this.limitAmount,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [id, icon, name, color, limitAmount, lastUpdated];
}
