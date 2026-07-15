part of 'category_limits_bloc.dart';

abstract class CategoryLimitsState extends Equatable {
  const CategoryLimitsState();
  
  @override
  List<Object?> get props => [];
}

class CategoryLimitsInitial extends CategoryLimitsState {}

class CategoryLimitsLoading extends CategoryLimitsState {}

class CategoryLimitsLoaded extends CategoryLimitsState {
  final List<CategoryLimitEntity> limits;
  final String? expandedCategoryId;
  final String? searchQuery;

  const CategoryLimitsLoaded({
    required this.limits,
    this.expandedCategoryId,
    this.searchQuery,
  });

  CategoryLimitsLoaded copyWith({
    List<CategoryLimitEntity>? limits,
    String? expandedCategoryId,
    String? searchQuery,
    bool clearExpandedId = false,
  }) {
    return CategoryLimitsLoaded(
      limits: limits ?? this.limits,
      expandedCategoryId: clearExpandedId ? null : (expandedCategoryId ?? this.expandedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [limits, expandedCategoryId, searchQuery];
}

class CategoryLimitsError extends CategoryLimitsState {
  final String message;

  const CategoryLimitsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Action states for saving/deleting limits without wiping out the list UI
class CategoryLimitsActionLoading extends CategoryLimitsState {}

class CategoryLimitsActionSuccess extends CategoryLimitsState {
  final String message;

  const CategoryLimitsActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class CategoryLimitsActionError extends CategoryLimitsState {
  final String message;

  const CategoryLimitsActionError({required this.message});

  @override
  List<Object?> get props => [message];
}
