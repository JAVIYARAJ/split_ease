import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/utils/error_message_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AccountRemoteDataSource {
  Future<bool> logout();
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
}
