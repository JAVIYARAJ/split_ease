
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/utils/error_message_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AccountRemoteDataSource {
  Future<bool> logout();
  Future<bool> submitAppFeedback(int rating, String description);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final SupabaseClient client;

  AccountRemoteDataSourceImpl(this.client);

  @override
  Future<bool> logout() async {
    try {
      await client.auth.signOut();
      return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<bool> submitAppFeedback(int rating, String description) async {
    try {
      await client.rpc('submit_app_feedback_rpc', params: {
        'p_rating': rating,
        'p_description': description,
      });
      return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }
}
