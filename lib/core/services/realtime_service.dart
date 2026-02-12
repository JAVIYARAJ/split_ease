import 'package:supabase_flutter/supabase_flutter.dart';

/// A service that manages Supabase Realtime channel subscriptions.
///
/// Currently supports listening for new friend requests on the `friendship` table.
class RealtimeService {
  final SupabaseClient _client;

  RealtimeChannel? _friendRequestChannel;

  RealtimeService({required SupabaseClient client}) : _client = client;

  /// Subscribe to new incoming friend requests for [userId].
  ///
  /// When a new row is inserted into the `friendship` table where
  /// `addressee_id` matches [userId], the service fetches full requester
  /// info from the `users` table and calls [onNewRequest] with it.
  ///
  /// The callback receives a Map with keys:
  /// `friendship_id`, `requester_id`, `full_name`, `email`, `avtar`, `requested_at`
  void subscribeFriendRequests({
    required String userId,
    required void Function(Map<String, dynamic> requesterInfo) onNewRequest,
  }) {
    // Unsubscribe from any existing channel first
    unsubscribeFriendRequests();

    _friendRequestChannel = _client
        .channel('friend-requests-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'friendship',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'addressee_id',
            value: userId,
          ),
          callback: (payload) async {
            final newRecord = payload.newRecord;

            // Only care about pending requests
            if (newRecord['status'] != 'pending') return;

            final requesterId = newRecord['requester_id'] as String;
            final friendshipId = newRecord['id'] as String;
            final createdAt = newRecord['created_at'] as String;

            try {
              // Fetch full requester info from users table
              final userData = await _client
                  .from('users')
                  .select('id, full_name, email, avtar')
                  .eq('id', requesterId)
                  .single();

              onNewRequest({
                'friendship_id': friendshipId,
                'requester_id': requesterId,
                'full_name': userData['full_name'] ?? 'Someone',
                'email': userData['email'],
                'avtar': userData['avtar'],
                'requested_at': createdAt,
              });
            } catch (_) {
              // Even if user lookup fails, still notify with basic info
              onNewRequest({
                'friendship_id': friendshipId,
                'requester_id': requesterId,
                'full_name': 'Someone',
                'email': null,
                'avtar': null,
                'requested_at': createdAt,
              });
            }
          },
        )
        .subscribe();
  }

  /// Unsubscribe from friend request updates.
  void unsubscribeFriendRequests() {
    if (_friendRequestChannel != null) {
      _client.removeChannel(_friendRequestChannel!);
      _friendRequestChannel = null;
    }
  }

  /// Dispose all channels.
  void dispose() {
    unsubscribeFriendRequests();
  }
}
