import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/utils/error_message_utils.dart';
import '../models/activity_model.dart';

abstract interface class ActivityRemoteDataSource {
  Future<List<ActivityModel>> getActivityFeed({int page = 1, int limit = 20});
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final SupabaseClient client;

  ActivityRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ActivityModel>> getActivityFeed({int page = 1, int limit = 20}) async {
    try {
      final response = await client.rpc('get_activity_feed_pagination_rpc', params: {
        'p_page': page,
        'p_limit': limit,
      });
      return (response as List).map((e) => ActivityModel.fromJson(e)).toList();
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }
}
