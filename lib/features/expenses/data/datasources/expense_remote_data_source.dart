import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';

import '../../../../core/error/exception.dart';

abstract class ExpenseRemoteDataSource {
  Future<void> createExpense(CreateExpenseParams params);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient client;

  ExpenseRemoteDataSourceImpl({required this.client});

  @override
  Future<void> createExpense(CreateExpenseParams params) async {
    try {
      final response = await client.rpc(
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
}
