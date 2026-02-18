import 'package:equatable/equatable.dart';

class GroupMemberEntity extends Equatable {
  final String? memberId;
  final String? userId;
  final String? fullName;
  final String? email;
  final String? role;
  final String? joinedAt;
  final String? avtar;

  const GroupMemberEntity({
    required this.memberId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.joinedAt,
    required this.avtar,
  });

  @override
  List<Object?> get props => [memberId, userId, fullName, email, role, joinedAt, avtar];
}
