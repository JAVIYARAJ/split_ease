import 'package:equatable/equatable.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';

abstract class FriendDetailEvent extends Equatable {
  const FriendDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriendDetails extends FriendDetailEvent {
  final FriendEntity friend;
  final bool hasChanges;

  const LoadFriendDetails({required this.friend, this.hasChanges = false});

  @override
  List<Object?> get props => [friend, hasChanges];
}

class LoadFriendExpenseHistory extends FriendDetailEvent {
  final String? friendId;

  const LoadFriendExpenseHistory({this.friendId});

  @override
  List<Object?> get props => [friendId];
}
