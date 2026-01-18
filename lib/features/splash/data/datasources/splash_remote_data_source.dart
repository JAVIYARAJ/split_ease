import 'package:split_ease/core/error/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SplashRemoteDataSource {
  Future<bool> isUserLogin();
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final SupabaseClient client;

  SplashRemoteDataSourceImpl({required this.client});

  @override
  Future<bool> isUserLogin() async {
    try {
      return client.auth.currentUser != null;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
