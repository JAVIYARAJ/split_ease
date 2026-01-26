import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/utils/error_message_utils.dart';
import 'package:split_ease/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SplashRemoteDataSource {
  Future<UserModel> isUserLogin();
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final SupabaseClient client;

  SplashRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> isUserLogin() async {
    try {
      if (client.auth.currentUser != null) {
        return UserModel.fromSupabaseUser(client.auth.currentUser!);
      } else {
        throw ServerException(message: "User not login");
      }
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
}
