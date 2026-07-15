import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
import 'package:split_ease/features/expenses/domain/usecases/update_expense_params.dart';
import 'package:split_ease/core/utils/error_message_utils.dart';

import '../../../../core/error/exception.dart';

import 'package:split_ease/features/expenses/data/models/expense_detail_model.dart';
import 'package:split_ease/features/expenses/data/models/expense_category_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<void> createExpense(CreateExpenseParams params);
  Future<void> updateExpense(UpdateExpenseParams params);
  Future<ExpenseDetailModel> getExpenseDetail(String expenseId);
  Future<List<ExpenseCommentModel>> getExpenseComments(String expenseId);
  Future<void> deleteExpense(String expenseId);
  Future<void> restoreExpense(String expenseId);
  Future<List<ExpenseUserModel>> getExpenseParticipants({String? groupId, String? friendUserId});
  Future<void> addExpenseComment({required String expenseId, required String comment});
  Future<void> updateExpenseComment({required String commentId, required String comment});
  Future<void> deleteExpenseComment({required String commentId});
  Future<void> settleUp({
    required String toUserId,
    required double amount,
    String? groupId,
    String? note,
  });
  Future<List<ExpenseCategoryModel>> getExpenseCategories();
}


class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient client;

  ExpenseRemoteDataSourceImpl({required this.client});

  @override
  Future<void> createExpense(CreateExpenseParams params) async {
    try {
      await client.rpc(
        'create_expense_rpc',
        params: params.toJson(),
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> updateExpense(UpdateExpenseParams params) async {
    try {
      await client.rpc(
        'update_expense_new',
        params: params.toJson(),
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<ExpenseDetailModel> getExpenseDetail(String expenseId) async {
    try {
      final response = await client.rpc(
        'get_expense_detail_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );
      return ExpenseDetailModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<List<ExpenseCommentModel>> getExpenseComments(String expenseId) async {
    try {
      final response = await client.rpc(
        'get_expense_comments_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => ExpenseCommentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await client.rpc(
        'delete_expense_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
  
  @override
  Future<void> restoreExpense(String expenseId) async {
    try {
      await client.rpc(
        'restore_expense_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
  
  @override
  Future<List<ExpenseUserModel>> getExpenseParticipants({String? groupId, String? friendUserId}) async {
    try {
      final response = await client.rpc(
        'get_expense_participants_rpc',
        params: {
          'p_group_id': groupId,
          'p_friend_user_id': friendUserId,
        },
      );
      
      return (response as List)
          .map((e) => ExpenseUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> addExpenseComment({required String expenseId, required String comment}) async {
    try {
      await client.rpc(
        'add_expense_comment_rpc',
        params: {
          'p_expense_id': expenseId,
          'p_comment': comment,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> updateExpenseComment({required String commentId, required String comment}) async {
    try {
      await client.rpc(
        'update_expense_comment_rpc',
        params: {
          'p_comment_id': commentId,
          'p_comment': comment,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> deleteExpenseComment({required String commentId}) async {
    try {
      await client.rpc(
        'delete_expense_comment_rpc',
        params: {
          'p_comment_id': commentId,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> settleUp({
    required String toUserId,
    required double amount,
    String? groupId,
    String? note,
  }) async {
    try {
      await client.rpc(
        'settle_up_rpc',
        params: {
          'p_to_user_id': toUserId,
          'p_amount': amount,
          'p_group_id': groupId,
          'p_note': note,
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<List<ExpenseCategoryModel>> getExpenseCategories() async {
    try {
      final response = await client.rpc('get_expense_categories_rpc');
      return (response as List)
          .map((e) => ExpenseCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
}
