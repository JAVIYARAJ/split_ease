part of 'category_limits_bloc.dart';

abstract class CategoryLimitsEvent extends Equatable {
  const CategoryLimitsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoryLimitsEvent extends CategoryLimitsEvent {}

class SetCategoryLimitEvent extends CategoryLimitsEvent {
  final String categoryId;
  final double limitAmount;

  const SetCategoryLimitEvent({required this.categoryId, required this.limitAmount});

  @override
  List<Object?> get props => [categoryId, limitAmount];
}

class DeleteCategoryLimitEvent extends CategoryLimitsEvent {
  final String categoryId;

  const DeleteCategoryLimitEvent({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class ToggleCategoryLimitEvent extends CategoryLimitsEvent {
  final String? categoryId; // null to collapse all

  const ToggleCategoryLimitEvent({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class SearchCategoryLimitsEvent extends CategoryLimitsEvent {
  final String query;

  const SearchCategoryLimitsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}
