import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';

import '../../../../core/error/exception.dart';

import 'package:split_ease/features/expenses/data/models/expense_detail_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<void> createExpense(CreateExpenseParams params);
  Future<ExpenseDetailModel> getExpenseDetail(String expenseId);
  Future<void> deleteExpense(String expenseId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient client;

  ExpenseRemoteDataSourceImpl({required this.client});

  @override
  Future<void> createExpense(CreateExpenseParams params) async {
    try {
      await client.rpc(
        'create_expense_rpc',
        params: {
          'p_group_id': params.groupId,
          'p_description': params.description,
          'p_total_amount': params.totalAmount,
          'p_paid_by': params.paidByUserId,
          'p_expense_date': params.expenseDate.toIso8601String().split('T')[0],
          'p_split_type': params.splitType,
          'p_splits': params.splits,
        },
      );

      // RPC returns a JSON object, if it throws it will be caught by catch block
      // Response might contain 'message' or 'expense_id' but we just need void on success
    } catch (e) {
      throw ServerException(message: e.toString());
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

      // The RPC returns a JSON object.
      return ExpenseDetailModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
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
      throw ServerException(message: e.toString());
    }
  }
}
