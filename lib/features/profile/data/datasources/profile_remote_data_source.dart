import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/utils/error_message_utils.dart';
import '../../../auth/data/models/user_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<UserModel> updateProfile({String? name, File? image});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient client;

  ProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> updateProfile({String? name, File? image}) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw ServerException(message: "User not logged in");
      }

      String? oldAvatarUrl = user.userMetadata?['avatar_url']; // Capture old URL

      String? imageUrl;
      if (image != null) {
        // Match AccountRemoteDataSource naming/path logic
        final userId = user.id;
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg'; // consistent with account
        final path = '$userId/$fileName';

        // Upload to 'user-icons' bucket (same as Account)
        await client.storage.from('user-icons').upload(
              path,
              image,
            );

        imageUrl = client.storage.from('user-icons').getPublicUrl(path);
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (imageUrl != null) updates['avatar_url'] = imageUrl;

      if (updates.isEmpty) {
         return UserModel.fromSupabaseUser(user);
      }

      // Update Auth User
      final response = await client.auth.updateUser(
        UserAttributes(data: updates),
      );

      if (response.user == null) {
        throw ServerException(message: "Failed to update profile");
      }

      // ALSO update 'users' table (as per AccountRemoteDataSource)
      if (imageUrl != null) {
         await client.from("users").update({"avtar": imageUrl}).eq("id", user.id);
         
         // Delete old image if exists and we are updating to a new one
         if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
           try {
             // Extract path from URL: .../user-icons/userId/filename.jpg -> userId/filename.jpg
             // Checks if URL contains 'user-icons' to be safe
             if (oldAvatarUrl.contains('user-icons')) {
                final path = oldAvatarUrl.split('user-icons/').last;
                if (path.isNotEmpty) {
                  await client.storage.from('user-icons').remove([path]);
                }
             }
           } catch (e) {
             // specific delete error shouldn't fail the whole profile update process, so we just log or ignore
             // but strictly we might want to know. For now, swallow it as non-critical or log.
           }
         }
      }
      // Note: AccountDataSource only showed updating 'avtar'. If name is updated, should we update 'users' too?
      // AccountDataSource didn't show name update logic. But assuming 'users' table mirrors auth, we should probably update name too if it exists there.
      // Checking UserModel.fromJson: name comes from json['name'] ?? json['full_name'].
      // To be safe and "complete" for profile, let's update name in 'users' if it exists.
      // Safe map for 'users' table:
      final userTableUpdates = <String, dynamic>{};
      if (imageUrl != null) userTableUpdates['avtar'] = imageUrl;
      // if (name != null) userTableUpdates['full_name'] = name; // Assuming column name. AccountDS used 'avtar'.
      // I will only update 'avtar' as requested (same image process).
      // Leaving name update for 'users' table out strictly unless I know column name.
      // But I will stick to what AccountDS does: updates 'avtar'.

      if (userTableUpdates.isNotEmpty) {
          await client.from("users").update(userTableUpdates).eq("id", user.id);
      }

      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw ServerException(message: ErrorMessageUtils.generate(e));
    }
  }
}
