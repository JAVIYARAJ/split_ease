import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/utils/error_message_utils.dart';
import '../models/recurring_expense_model.dart';

abstract class RecurringExpenseRemoteDataSource {
  Future<List<RecurringExpenseModel>> getRecurringExpenses();
  Future<String> saveRecurringExpenseTemplate({
    String? templateId,
    required String title,
    required double amount,
    required String categoryId,
    required String frequency,
    required int dueDay,
    required bool autoRemind,
  });
  Future<void> togglePauseRecurringExpense(String templateId, bool isPaused);
  Future<void> deleteRecurringExpense(String templateId);
  Future<void> confirmRecurringExpense(String templateId);
}

class RecurringExpenseRemoteDataSourceImpl
    implements RecurringExpenseRemoteDataSource {
  final SupabaseClient client;

  RecurringExpenseRemoteDataSourceImpl({required this.client});

  @override
  Future<List<RecurringExpenseModel>> getRecurringExpenses() async {
    try {
      final response = await client.rpc('get_recurring_expenses_rpc');
      if (response is List) {
        return response
            .map((e) => RecurringExpenseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<String> saveRecurringExpenseTemplate({
    String? templateId,
    required String title,
    required double amount,
    required String categoryId,
    required String frequency,
    required int dueDay,
    required bool autoRemind,
  }) async {
    try {
      final params = <String, dynamic>{
        'p_title': title,
        'p_amount': amount,
        'p_category_id': categoryId,
        'p_frequency': frequency,
        'p_due_day': dueDay,
        'p_auto_remind': autoRemind,
      };

      if (templateId != null && templateId.isNotEmpty && !templateId.startsWith('rec_')) {
        params['p_template_id'] = templateId;
      }

      final response = await client.rpc(
        'save_recurring_expense_template_rpc',
        params: params,
      );

      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return response['template_id']?.toString() ?? templateId ?? '';
        } else {
          throw ServerException(
              message: response['message']?.toString() ?? 'Failed to save recurring template');
        }
      }
      return templateId ?? '';
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> togglePauseRecurringExpense(String templateId, bool isPaused) async {
    try {
      final response = await client.rpc(
        'toggle_pause_recurring_expense_rpc',
        params: {
          'p_template_id': templateId,
          'p_is_paused': isPaused,
        },
      );
      if (response is Map<String, dynamic> && response['success'] == false) {
        throw ServerException(
            message: response['message']?.toString() ?? 'Failed to toggle pause status');
      }
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> deleteRecurringExpense(String templateId) async {
    try {
      final response = await client.rpc(
        'delete_recurring_expense_rpc',
        params: {
          'p_template_id': templateId,
        },
      );
      if (response is Map<String, dynamic> && response['success'] == false) {
        throw ServerException(
            message: response['message']?.toString() ?? 'Failed to delete template');
      }
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> confirmRecurringExpense(String templateId) async {
    try {
      final response = await client.rpc(
        'confirm_recurring_expense_rpc',
        params: {
          'p_template_id': templateId,
        },
      );
      if (response is Map<String, dynamic> && response['success'] == false) {
        throw ServerException(
            message: response['message']?.toString() ?? 'Failed to confirm recurring expense');
      }
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
}
