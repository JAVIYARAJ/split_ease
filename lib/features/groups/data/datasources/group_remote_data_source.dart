import 'dart:io';
import 'package:split_ease/core/utils/error_message_utils.dart';
import 'package:split_ease/features/groups/data/models/group_expense_history_model.dart';
import 'package:split_ease/features/groups/data/models/group_friend_model.dart';
import 'package:split_ease/features/groups/data/models/group_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exception.dart';
import '../models/group_member_model.dart';

abstract interface class GroupRemoteDataSource {
  Future<String> insertGroupImage(File file);

  Future<dynamic> createGroup(String name, String type, String? icon, String inviteCode);

  Future<List<GroupModel>> getAllGroups();

  Future<GroupModel> getGroupDetail(String id);

  Future<bool> checkInviteCode(String code);

  Future<String?> joinGroup(String code);

  Future<bool> leaveGroup(String groupId);

  Future<bool> deleteGroup(String groupId);

  Future<bool> updateGroup(String id, String name, String type, String? icon,String inviteCode);

  Future<List<GroupFriendModel>> getFriendsWithGroupStatus(String groupId);

  Future<void> addMultipleFriendsToGroup(String groupId, List<String> userIds);

  Future<GroupExpenseHistoryModel> getGroupExpenseHistory(String groupId);

  Future<List<GroupMemberModel>> getGroupMembers(String groupId);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final SupabaseClient client;

  GroupRemoteDataSourceImpl({required this.client});

  @override
  Future<String> insertGroupImage(File file) async {
    try {
      final groupId = const Uuid().v4();
      final fileName = file.path.split('/').last;
      final path = '$groupId/$fileName';

      // Upload
      await client.storage.from('group-icons').upload(path, file);

      // Get full public URL
      final publicUrl = client.storage.from('group-icons').getPublicUrl(path);

      return publicUrl; // ✅ full URL
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<dynamic> createGroup(String name, String type, String? icon, String inviteCode) async {
    try {
      var payload = {"name": name, "group_type": type, "group_icon": icon,"invite_code": inviteCode};
      var response = await client.from("group").insert(payload).select();
      return response;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<List<GroupModel>> getAllGroups() async {
    try {

      final response = await client
          .rpc("get_my_groups_dashboard_rpc");

      return (response as List)
          .map((e) => GroupModel.fromJson(e))
          .toList();
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<GroupModel> getGroupDetail(String id) async {
    try {
      var response = await client.rpc("get_group_detail",params: {
        "p_group_id":id
      });
      return GroupModel.fromJson(response);
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<bool> checkInviteCode(String code) async {
    try {
      var response = await client.from("group").select("invite_code").eq("invite_code", code);
      return response.isNotEmpty;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<String?> joinGroup(String code) async {
    try {
      final response = await client.rpc(
        'join_group_by_code',
        params: {
          'p_invite_code': code,
        },
      );

      if (response == true) {
        // If join successful, fetch group details
        final groupResponse = await client.from("group").select().eq("invite_code", code).single();
        return groupResponse["id"];
      } else {
        throw ServerException(message: "Failed to join group");
      }
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<bool> leaveGroup(String groupId) async {
    try {
      final userId = client.auth.currentUser!.id;
      
      // We will use an RPC to ensure safety
      await client.rpc('leave_group', params: {'p_group_id': groupId, 'p_user_id': userId});
      
      return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<bool> deleteGroup(String groupId) async {
    try {
        await client.from('group').delete().eq('id', groupId);
        return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<bool> updateGroup(String id, String name, String type, String? icon,String inviteCode) async {
    try {
      var payload = {"name": name, "group_type": type, if(icon != null) "group_icon": icon,"invite_code":inviteCode};
      await client.from("group").update(payload).eq("id", id);
      return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<List<GroupFriendModel>> getFriendsWithGroupStatus(String groupId) async {
    try {
      final response = await client.rpc(
        'get_my_friends_with_group_status_rpc',
        params: {'p_group_id': groupId},
      );
      return (response as List).map((e) => GroupFriendModel.fromJson(e)).toList();
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<void> addMultipleFriendsToGroup(String groupId, List<String> userIds) async {
    try {
      await client.rpc(
        'add_multiple_friends_to_group_rpc',
        params: {
          'p_group_id': groupId,
          'p_user_ids': userIds,
        },
      );
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<GroupExpenseHistoryModel> getGroupExpenseHistory(String groupId) async {
    try {
      final response = await client.rpc(
        'get_group_detail_dashboard_rpc',
        params: {'p_group_id': groupId},
      );
      return GroupExpenseHistoryModel.fromJson(response as Map<String, dynamic>);
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<List<GroupMemberModel>> getGroupMembers(String groupId) async {
    try {
      final response = await client.rpc(
        'get_group_members_rpc',
        params: {'p_group_id': groupId},
      );
      return (response as List).map((e) => GroupMemberModel.fromJson(e)).toList();
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }
}