import 'package:google_sign_in/google_sign_in.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/secrets/app_secrets.dart';
import 'package:split_ease/core/utils/error_message_utils.dart';
import 'package:split_ease/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword({required String name, required String email, required String password});

  Future<UserModel> loginWithEmailPassword({required String email, required String password});

  Future<UserModel?> getCurrentUser();
  Future<void> resendConfirmationEmail({required String email});

  /// Returns null when the user cancels the Google sign-in sheet.
  Future<UserModel?> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl({required this.client});

  Future<UserModel> _fetchProfile(User user) async {
    try {
      final profileData = await client.rpc('get_my_profile_rpc');
      if (profileData != null) {
        return UserModel.fromJson(profileData as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback if RPC fails
    }
    return UserModel.fromSupabaseUser(user);
  }

  @override
  Future<UserModel> loginWithEmailPassword({required String email, required String password}) async {
    try {
      var response = await client.auth.signInWithPassword(password: password, email: email);
      if (response.user == null) {
        throw ServerException(message: "user is null");
      } else {
        return await _fetchProfile(response.user!);
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
        return await _fetchProfile(response.user!);
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
        return await _fetchProfile(user);
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

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: AppSecrets.googleIosClientId,
        serverClientId: AppSecrets.googleWebClientId,
      );

      // Make sure we start from a clean slate so the chooser always appears.
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw ServerException(message: 'Google did not return an ID token.');
      }

      final response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw ServerException(message: 'Supabase did not return a user.');
      }

      return await _fetchProfile(response.user!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
}
