import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/account/domain/entities/category_limit_entity.dart';
import 'package:split_ease/features/account/domain/usecases/delete_category_limit.dart';
import 'package:split_ease/features/account/domain/usecases/get_category_limits.dart';
import 'package:split_ease/features/account/domain/usecases/set_category_limit.dart';

part 'category_limits_event.dart';
part 'category_limits_state.dart';

class CategoryLimitsBloc extends Bloc<CategoryLimitsEvent, CategoryLimitsState> {
  final GetCategoryLimits getCategoryLimits;
  final SetCategoryLimit setCategoryLimit;
  final DeleteCategoryLimit deleteCategoryLimit;

  CategoryLimitsBloc({
    required this.getCategoryLimits,
    required this.setCategoryLimit,
    required this.deleteCategoryLimit,
  }) : super(CategoryLimitsInitial()) {
    on<LoadCategoryLimitsEvent>(_onLoadCategoryLimits);
    on<SetCategoryLimitEvent>(_onSetCategoryLimit);
    on<DeleteCategoryLimitEvent>(_onDeleteCategoryLimit);
    on<ToggleCategoryLimitEvent>(_onToggleCategoryLimit);
    on<SearchCategoryLimitsEvent>(_onSearchCategoryLimits);
  }

  Future<void> _onLoadCategoryLimits(LoadCategoryLimitsEvent event, Emitter<CategoryLimitsState> emit) async {
    emit(CategoryLimitsLoading());
    final result = await getCategoryLimits(NoParams());
    result.fold(
      (failure) => emit(CategoryLimitsError(message: failure.message)),
      (limits) => emit(CategoryLimitsLoaded(limits: limits)),
    );
  }

  Future<void> _onSetCategoryLimit(SetCategoryLimitEvent event, Emitter<CategoryLimitsState> emit) async {
    emit(CategoryLimitsActionLoading());
    final result = await setCategoryLimit(SetCategoryLimitParams(categoryId: event.categoryId, limitAmount: event.limitAmount));
    result.fold(
      (failure) => emit(CategoryLimitsActionError(message: failure.message)),
      (_) {
        emit(CategoryLimitsActionSuccess(message: 'Limit saved successfully'));
        add(LoadCategoryLimitsEvent());
      },
    );
  }

  Future<void> _onDeleteCategoryLimit(DeleteCategoryLimitEvent event, Emitter<CategoryLimitsState> emit) async {
    emit(CategoryLimitsActionLoading());
    final result = await deleteCategoryLimit(DeleteCategoryLimitParams(categoryId: event.categoryId));
    result.fold(
      (failure) => emit(CategoryLimitsActionError(message: failure.message)),
      (_) {
        emit(const CategoryLimitsActionSuccess(message: 'Limit removed successfully'));
        add(LoadCategoryLimitsEvent());
      },
    );
  }

  void _onToggleCategoryLimit(ToggleCategoryLimitEvent event, Emitter<CategoryLimitsState> emit) {
    if (state is CategoryLimitsLoaded) {
      final currentState = state as CategoryLimitsLoaded;
      if (currentState.expandedCategoryId == event.categoryId) {
        emit(currentState.copyWith(clearExpandedId: true));
      } else {
        emit(currentState.copyWith(expandedCategoryId: event.categoryId));
      }
    }
  }

  void _onSearchCategoryLimits(SearchCategoryLimitsEvent event, Emitter<CategoryLimitsState> emit) {
    if (state is CategoryLimitsLoaded) {
      final currentState = state as CategoryLimitsLoaded;
      emit(currentState.copyWith(searchQuery: event.query, clearExpandedId: true));
    }
  }
}
