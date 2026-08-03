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

  Future<dynamic> createGroup(
    String name,
    String type,
    String? icon,
    String inviteCode, {
    String? destination,
    String? startDate,
    String? endDate,
    double? budget,
  });

  Future<List<GroupModel>> getAllGroups();

  Future<GroupModel> getGroupDetail(String? id);

  Future<bool> checkInviteCode(String code);

  Future<String?> joinGroup(String code);

  Future<bool> leaveGroup(String groupId);

  Future<bool> removeMember(String groupId, String userId);

  Future<bool> deleteGroup(String groupId);

  Future<bool> updateGroup(
    String id,
    String name,
    String type,
    String? icon,
    String inviteCode, {
    String? destination,
    String? startDate,
    String? endDate,
    double? budget,
  });

  Future<List<GroupFriendModel>> getFriendsWithGroupStatus(String groupId);

  Future<void> addMultipleFriendsToGroup(String groupId, List<String> userIds, {Map<String, String>? roles});

  Future<GroupExpenseHistoryModel> getGroupExpenseHistory(String? groupId);

  Future<List<GroupMemberModel>> getGroupMembers(String groupId);
  
  Future<List<GroupModel>> getCommonGroupsForUsers(List<String> userIds);

  Future<bool> updateGroupMemberRole(String groupId, String userId, String newRole);
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
  Future<dynamic> createGroup(
    String name,
    String type,
    String? icon,
    String inviteCode, {
    String? destination,
    String? startDate,
    String? endDate,
    double? budget,
  }) async {
    try {
      var payload = {
        "name": name,
        "group_type": type,
        "group_icon": icon,
        "invite_code": inviteCode,
        "destination": ?destination,
        "start_date": ?startDate,
        "end_date": ?endDate,
        "budget": ?budget,
      };
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
  Future<GroupModel> getGroupDetail(String? id) async {
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
      await client.rpc('remove_or_leave_group_member_rpc', params: {
        'p_group_id': groupId, 
        'p_target_user_id': userId
      });
      return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<bool> removeMember(String groupId, String userId) async {
    try {
      await client.rpc('remove_or_leave_group_member_rpc', params: {
        'p_group_id': groupId, 
        'p_target_user_id': userId
      });
      return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<bool> deleteGroup(String groupId) async {
    try {
        await client.rpc('delete_group_rpc', params: {'p_group_id': groupId});
        return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }


  @override
  Future<bool> updateGroup(
    String id,
    String name,
    String type,
    String? icon,
    String inviteCode, {
    String? destination,
    String? startDate,
    String? endDate,
    double? budget,
  }) async {
    try {
      var payload = {
        "name": name,
        "group_type": type,
        "group_icon": ?icon,
        "invite_code": inviteCode,
        "destination": destination,
        "start_date": startDate,
        "end_date": endDate,
        "budget": budget,
      };
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
  Future<void> addMultipleFriendsToGroup(String groupId, List<String> userIds, {Map<String, String>? roles}) async {
    try {
      final membersList = userIds.map((id) => {
        'user_id': id,
        'role': roles?[id] ?? 'user',
      }).toList();

      await client.rpc(
        'add_multiple_friends_to_group_rpc',
        params: {
          'p_group_id': groupId,
          'p_members': membersList,
        },
      );
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<GroupExpenseHistoryModel> getGroupExpenseHistory(String? groupId) async {
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

  @override
  Future<List<GroupModel>> getCommonGroupsForUsers(List<String> userIds) async {
    try {
      final response = await client.rpc(
        'get_common_groups_for_users_rpc',
        params: {'p_user_ids': userIds},
      );
      return (response as List).map((e) => GroupModel.fromJson(e)).toList();
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<bool> updateGroupMemberRole(String groupId, String userId, String newRole) async {
    try {
      await client.rpc('update_group_member_role_rpc', params: {
        'p_group_id': groupId,
        'p_target_user_id': userId,
        'p_new_role': newRole,
      });
      return true;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }
}