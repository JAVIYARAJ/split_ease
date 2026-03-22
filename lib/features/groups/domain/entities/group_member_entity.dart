import 'package:equatable/equatable.dart';

class GroupMemberEntity extends Equatable {
  final String? userId;
  final String? fullName;
  final String? email;
  final String? role;
  final String? avtar;

  const GroupMemberEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.role,
    this.avtar,
  });

  @override
  List<Object?> get props => [userId, fullName, email, role, avtar];
}
