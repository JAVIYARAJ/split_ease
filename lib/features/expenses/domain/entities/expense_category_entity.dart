import 'package:equatable/equatable.dart';

class ExpenseCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isDefault;

  const ExpenseCategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [id, name, icon, color, isDefault];
}
