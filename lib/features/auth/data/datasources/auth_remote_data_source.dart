import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/utils/error_message_utils.dart';
import 'package:split_ease/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword({required String name, required String email, required String password});

  Future<UserModel> loginWithEmailPassword({required String email, required String password});

  Future<UserModel?> getCurrentUser();
  Future<void> resendConfirmationEmail({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> loginWithEmailPassword({required String email, required String password}) async {
    try {
      var response = await client.auth.signInWithPassword(password: password, email: email);
      if (response.user == null) {
        throw ServerException(message: "user is null");
      } else {
        return UserModel.fromSupabaseUser(response.user!);
      }
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({required String name, required String email, required String password}) async {
    try {
      var response = await client.auth.signUp(password: password, email: email, data: {'name': name});
      if (response.user == null) {
        throw ServerException(message: "user is null");
      } else {
        return UserModel.fromSupabaseUser(response.user!);
      }
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }
      return null;
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }

  @override
  Future<void> resendConfirmationEmail({required String email}) async {
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
}
