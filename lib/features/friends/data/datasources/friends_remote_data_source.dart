import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/utils/error_message_utils.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';
import '../models/friend_expense_history_model.dart';

abstract interface class FriendsRemoteDataSource {
  Future<dynamic> joinFriends(String friendId);
  Future<List<FriendModel>> getMyFriends();
  Future<List<FriendRequestModel>> getFriendRequests();
  Future<void> respondToFriendRequest(String friendshipId, String action);
  Future<int> getUnreadFriendRequestCount();
  Future<FriendExpenseHistoryModel> getFriendExpenseHistory(String friendId);
}

class FriendRemoteDatSourceImpl implements FriendsRemoteDataSource {
  final SupabaseClient client;

  FriendRemoteDatSourceImpl({required this.client});

  @override
  Future<dynamic> joinFriends(String friendId) async {
    try {
      await client.rpc(
        'send_friend_request_rpc',
        params: {
          'p_addressee_id': friendId,
        },
      );
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<List<FriendModel>> getMyFriends() async {
    try {
      final response = await client.rpc('get_my_friends_rpc_v2');
      return (response as List).map((e) => FriendModel.fromJson(e)).toList();
    }catch(error){
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<List<FriendRequestModel>> getFriendRequests() async {
    try {
      final response = await client.rpc('get_my_pending_requests_rpc');
      return (response as List).map((e) => FriendRequestModel.fromJson(e)).toList();
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<void> respondToFriendRequest(String friendshipId, String action) async {
    try {
      await client.rpc(
        'respond_to_friend_request_rpc',
        params: {
          'p_friendship_id': friendshipId,
          'p_action': action,
        },
      );
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<int> getUnreadFriendRequestCount() async {
    try {
      final response = await client.rpc('get_unread_friend_request_count_rpc');
      return (response as int?) ?? 0;
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }

  @override
  Future<FriendExpenseHistoryModel> getFriendExpenseHistory(String friendId) async {
    try {
      final response = await client.rpc(
        'get_friend_detail_dashboard_rpc', // Using this as requested in the plan
        params: {'p_user_id': friendId},
      );
      return FriendExpenseHistoryModel.fromJson(response as Map<String, dynamic>);
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }
}
