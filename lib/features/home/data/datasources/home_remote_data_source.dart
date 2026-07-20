import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/home_dashboard_model.dart';
import 'package:split_ease/core/error/exception.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDashboardModel> getHomeDashboard({DateTime? startDate, DateTime? endDate});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<HomeDashboardModel> getHomeDashboard({DateTime? startDate, DateTime? endDate}) async {
    try {
      final response = await supabaseClient.rpc(
        'get_expense_summary_rpc',
        params: {
          if (startDate != null) 'p_start_date': startDate.toIso8601String(),
          if (endDate != null) 'p_end_date': endDate.toIso8601String(),
        },
      );
      return HomeDashboardModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
