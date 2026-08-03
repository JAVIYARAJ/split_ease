part of 'create_group_bloc.dart';

abstract class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();

  @override
  List<Object?> get props => [];
}

class SelectGroupType extends CreateGroupEvent {
  final GroupType type;

  const SelectGroupType(this.type);

  @override
  List<Object?> get props => [type];
}

class PickGroupImage extends CreateGroupEvent {
  const PickGroupImage();

  @override
  List<Object?> get props => [];
}

class CreateGroupSubmitted extends CreateGroupEvent {
  final String name;
  final GroupType type;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final double? budget;

  const CreateGroupSubmitted({
    required this.name,
    required this.type,
    this.destination,
    this.startDate,
    this.endDate,
    this.budget,
  });

  @override
  List<Object?> get props => [name, type, destination, startDate, endDate, budget];
}

class GenerateInviteCode extends CreateGroupEvent {
  const GenerateInviteCode();
}

class InitializeCreateGroup extends CreateGroupEvent {
  final GroupEntity? group;

  const InitializeCreateGroup({this.group});

  @override
  List<Object?> get props => [group];
}

class UpdateGroupSubmitted extends CreateGroupEvent {
  final String groupId;
  final String name;
  final GroupType type;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final double? budget;

  const UpdateGroupSubmitted({
    required this.groupId,
    required this.name,
    required this.type,
    this.destination,
    this.startDate,
    this.endDate,
    this.budget,
  });

  @override
  List<Object?> get props => [groupId, name, type, destination, startDate, endDate, budget];
}
