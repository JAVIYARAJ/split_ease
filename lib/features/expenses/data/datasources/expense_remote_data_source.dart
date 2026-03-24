import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
import 'package:split_ease/features/expenses/domain/usecases/update_expense_params.dart';


import '../../../../core/error/exception.dart';

import 'package:split_ease/features/expenses/data/models/expense_detail_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<void> createExpense(CreateExpenseParams params);
  Future<void> updateExpense(UpdateExpenseParams params);
  Future<ExpenseDetailModel> getExpenseDetail(String expenseId);
  Future<void> deleteExpense(String expenseId);
  Future<List<ExpenseUserModel>> getExpenseParticipants({String? groupId, String? friendUserId});
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

      // RPC returns a JSON object, if it throws it will be caught by catch block
      // Response might contain 'message' or 'expense_id' but we just need void on success
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  @override
  Future<void> updateExpense(UpdateExpenseParams params) async {
    try {
      await client.rpc(
        'update_expense_rpc',
        params: params.toJson(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override

  Future<ExpenseDetailModel> getExpenseDetail(String expenseId) async {
   // try {
      final response = await client.rpc(
        'get_expense_detail_rpc',
        params: {
          'p_expense_id': expenseId,
        },
      );

      // The RPC returns a JSON object.
      return ExpenseDetailModel.fromJson(response as Map<String, dynamic>);
    // } catch (e) {
    //   throw ServerException(message: e.toString());
    // }
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
      throw ServerException(message: e.toString());
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
      throw ServerException(message: e.toString());
    }
  }
}
