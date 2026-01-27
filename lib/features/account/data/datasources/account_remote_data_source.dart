import 'dart:io';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/utils/error_message_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AccountRemoteDataSource {
  Future<bool> logout();

  Future<String> uploadProfilePicture(File image);
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
  Future<String> uploadProfilePicture(File image) async {
    try {
      final userId = client.auth.currentUser!.id;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';

      // Upload
      await client.storage.from('user-icons').upload(path, image);

      // Get public URL
      final publicUrl = client.storage.from('user-icons').getPublicUrl(path);

      // Update user metadata with new avatar URL
      await client.auth.updateUser(UserAttributes(
        data: {'avatar_url': publicUrl},
      ));

      await client.from("users").update({"avtar":publicUrl}).eq("id", userId);

      return publicUrl;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }
}
