
part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final File? pickedImage;
  final String? errorMessage;
  final UserEntity? user; // For success payload

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.pickedImage,
    this.errorMessage,
    this.user,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    File? pickedImage,
    String? errorMessage,
    UserEntity? user,
  }) {
    return ProfileState(
      status: status ?? this.status,
      pickedImage: pickedImage ?? this.pickedImage,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, pickedImage, errorMessage, user];
}
