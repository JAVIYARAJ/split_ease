part of 'create_group_bloc.dart';


class CreateGroupState extends Equatable {
  final GroupType selectedType;
  final File? groupImage;
  final CreateGroupStatus status;
  final String? errorMessage;
  final String? createdGroupId;
  final String inviteCode;
  final bool isGeneratingCode;
  final bool isEditMode;
  final String? existingIconUrl;

  const CreateGroupState({
    this.selectedType = GroupType.other,
    this.groupImage,
    this.status = CreateGroupStatus.initial,
    this.errorMessage,
    this.createdGroupId,
    this.inviteCode = '',
    this.isGeneratingCode = false,
    this.isEditMode = false,
    this.existingIconUrl,
  });

  CreateGroupState copyWith({
    GroupType? selectedType,
    File? groupImage,
    CreateGroupStatus? status,
    String? errorMessage,
    String? createdGroupId,
    String? inviteCode,
    bool? isGeneratingCode,
    bool? isEditMode,
    String? existingIconUrl,
  }) {
    return CreateGroupState(
      selectedType: selectedType ?? this.selectedType,
      groupImage: groupImage ?? this.groupImage,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdGroupId: createdGroupId ?? this.createdGroupId,
      inviteCode: inviteCode ?? this.inviteCode,
      isGeneratingCode: isGeneratingCode ?? this.isGeneratingCode,
      isEditMode: isEditMode ?? this.isEditMode,
      existingIconUrl: existingIconUrl ?? this.existingIconUrl,
    );
  }

  @override
  List<Object?> get props => [selectedType, groupImage, status, errorMessage, createdGroupId, inviteCode, isGeneratingCode, isEditMode, existingIconUrl];
}
