import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/home_dashboard_model.dart';
import '../models/advertisement_model.dart';
import 'package:split_ease/core/error/exception.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDashboardModel> getHomeDashboard({DateTime? startDate, DateTime? endDate});
  Future<List<AdvertisementModel>> getAdvertisements(DateTime clientDate);
  Future<void> updateUserLastActive(String userId);
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

  @override
  Future<List<AdvertisementModel>> getAdvertisements(DateTime clientDate) async {
    try {
      final response = await supabaseClient.rpc(
        'get_active_advertisements',
        params: {
          'p_client_date': clientDate.toIso8601String(),
        },
      );
      if (response is List) {
        return response
            .map((e) => AdvertisementModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateUserLastActive(String userId) async {
    try {
      await supabaseClient.rpc(
        'update_user_last_active_rpc',
        params: {
          'p_user_id': userId,
        },
      );
    } catch (_) {
      // Background activity update failure ignored silently
    }
  }
}


