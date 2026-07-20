import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:split_ease/core/error/exception.dart';
import '../models/expense_breakdown_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<ExpenseBreakdownModel> getExpenseBreakdown({
    String? startDate,
    String? endDate,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final SupabaseClient supabaseClient;

  AnalyticsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ExpenseBreakdownModel> getExpenseBreakdown({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['p_start_date'] = startDate;
      if (endDate != null) params['p_end_date'] = endDate;
      final response = await supabaseClient.rpc(
        'get_expense_breakdown_rpc',
        params: params.isEmpty ? null : params,
      );
      return ExpenseBreakdownModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
