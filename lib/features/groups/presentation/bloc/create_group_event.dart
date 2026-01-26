part of 'create_group_bloc.dart';

abstract class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();

  @override
  List<Object> get props => [];
}

class SelectGroupType extends CreateGroupEvent {
  final GroupType type;

  const SelectGroupType(this.type);

  @override
  List<Object> get props => [type];
}

class PickGroupImage extends CreateGroupEvent {
  const PickGroupImage();

  @override
  List<Object> get props => [];
}

class CreateGroupSubmitted extends CreateGroupEvent {
  final String name;
  final GroupType type;

  const CreateGroupSubmitted({required this.name, required this.type});

  @override
  List<Object> get props => [name, type];
}

class GenerateInviteCode extends CreateGroupEvent {
  const GenerateInviteCode();
}
