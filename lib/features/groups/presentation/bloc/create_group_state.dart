part of 'create_group_bloc.dart';

enum CreateGroupStatus { initial, loading, success, failure }

class CreateGroupState extends Equatable {
  final GroupType selectedType;
  final File? groupImage;
  final CreateGroupStatus status;
  final String? errorMessage;
  final String? createdGroupId;
  final String inviteCode;
  final bool isGeneratingCode;

  const CreateGroupState({
    this.selectedType = GroupType.trip,
    this.groupImage,
    this.status = CreateGroupStatus.initial,
    this.errorMessage,
    this.createdGroupId,
    this.inviteCode = '',
    this.isGeneratingCode = false,
  });

  CreateGroupState copyWith({
    GroupType? selectedType,
    File? groupImage,
    CreateGroupStatus? status,
    String? errorMessage,
    String? createdGroupId,
    String? inviteCode,
    bool? isGeneratingCode,
  }) {
    return CreateGroupState(
      selectedType: selectedType ?? this.selectedType,
      groupImage: groupImage ?? this.groupImage,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdGroupId: createdGroupId ?? this.createdGroupId,
      inviteCode: inviteCode ?? this.inviteCode,
      isGeneratingCode: isGeneratingCode ?? this.isGeneratingCode,
    );
  }

  @override
  @override
  List<Object?> get props => [selectedType, groupImage, status, errorMessage, createdGroupId, inviteCode, isGeneratingCode];
}
