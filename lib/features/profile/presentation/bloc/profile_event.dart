
part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class PickProfileImage extends ProfileEvent {
  final ImageSource source;

  const PickProfileImage(this.source);

  @override
  List<Object> get props => [source];
}

class UpdateProfile extends ProfileEvent {
  final String? name;
  // Encapsulated image in state, but can still accept it or rely on state. 
  // User input 'name' is usually passed from UI controller at submission time.
  // Image is already in state, so we might not need it here, but keeping it flexible.
  // Actually, adhering to "remove setState", the name controller text is still UI state (TextEditingController). 
  // It's standard to keep Controller in UI.
  // The BLoC will use the `pickedImage` from its own state if not passed, or we can pass it. 
  // For cleanliness, let's keep name here.

  const UpdateProfile({this.name});

  @override
  List<Object> get props => [name ?? ''];
}
