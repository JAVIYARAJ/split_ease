import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/friend_entity.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  FriendsBloc() : super(FriendsInitial()) {
    on<LoadFriends>(_onLoadFriends);
  }

  Future<void> _onLoadFriends(LoadFriends event, Emitter<FriendsState> emit) async {
    emit(FriendsLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock Data 
      // In a real app, this would come from a UseCase/Repository
      final List<FriendEntity> friends = [
        const FriendEntity(
          id: "1",
          name: "Alpesh sureja",
          balance: 246.33,
          activeGroup: "Trip",
        ),
        const FriendEntity(
          id: "2",
          name: "Bhavya Fultariya",
          balance: -173.34,
          imageUrl: "https://randomuser.me/api/portraits/men/1.jpg", 
          activeGroup: "Dinner",
        ),
        const FriendEntity(
          id: "3",
          name: "Bhruvik Mori",
          balance: 1388.36,
          activeGroup: "Events",
        ),
         const FriendEntity(
          id: "4",
          name: "Kavan patel",
          balance: 2471.09,
          imageUrl: "https://randomuser.me/api/portraits/men/2.jpg",
          activeGroup: "Parties",
        ),
        const FriendEntity(
          id: "5",
          name: "keval kadivar",
          balance: 0.0,
          activeGroup: "",
        ),
        const FriendEntity(
          id: "6",
          name: "Kevin Bhimani",
          balance: 927.30,
          imageUrl: "https://randomuser.me/api/portraits/men/3.jpg",
          activeGroup: "Esparkbiz",
        ),
        const FriendEntity(
          id: "7",
          name: "Meet Koradiya",
          balance: -856.28,
          activeGroup: "Project",
        ),
      ];

      emit(FriendsLoaded(friends));
    } catch (e) {
      emit(FriendsError("Failed to load friends"));
    }
  }
}
