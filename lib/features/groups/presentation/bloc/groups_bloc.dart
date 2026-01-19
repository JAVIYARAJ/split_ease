import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_balance_detail.dart';

part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  GroupsBloc() : super(GroupsInitial()) {
    on<LoadGroups>(_onLoadGroups);
  }

  Future<void> _onLoadGroups(LoadGroups event, Emitter<GroupsState> emit) async {
    emit(GroupsLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock Data 
      final List<GroupEntity> groups = [
        const GroupEntity(
          id: "1",
          name: "Chai and Chill",
          totalBalance: 3685.62,
          balanceDetails: [
            GroupBalanceDetail(memberName: "Kavan p.", amount: 1861.34, isOwedToUser: true),
            GroupBalanceDetail(memberName: "shira v.", amount: 1145.00, isOwedToUser: true),
            GroupBalanceDetail(memberName: "Bhavya", amount: 679.28, isOwedToUser: true),
          ],
        ),
        const GroupEntity(
          id: "2",
          name: "Esparkbiz",
          totalBalance: 2230.10,
          balanceDetails: [
            GroupBalanceDetail(memberName: "Milan C.", amount: 1652.80, isOwedToUser: true),
            GroupBalanceDetail(memberName: "Kevin B.", amount: 577.30, isOwedToUser: true),
          ],
        ),
        const GroupEntity(
          id: "3",
          name: "Karshmir trip",
          imageUrl: "https://images.unsplash.com/photo-1472214103451-9374bd1c798e", // Placeholder image from unsplash
          totalBalance: 960.40,
          balanceDetails: [
            GroupBalanceDetail(memberName: "Milan C.", amount: 551.40, isOwedToUser: true),
            GroupBalanceDetail(memberName: "Bhruvik M.", amount: 409.00, isOwedToUser: true),
          ],
        ),
        const GroupEntity(
          id: "4",
          name: "Matheran Trip",
          totalBalance: 1448.83,
            imageUrl: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34", // Travel icon placeholder equivalent
          balanceDetails: [
            GroupBalanceDetail(memberName: "Milan C.", amount: 1448.83, isOwedToUser: true),
          ],
        ),
        const GroupEntity(
          id: "5",
          name: "Navratri 2025",
          totalBalance: 834.29,
          balanceDetails: [
            GroupBalanceDetail(memberName: "Milan C.", amount: 469.28, isOwedToUser: true),
            GroupBalanceDetail(memberName: "Kevin B.", amount: 350.00, isOwedToUser: true),
            GroupBalanceDetail(memberName: "Other Member", amount: 14.01, isOwedToUser: true),
          ],
        ),
      ];

      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(GroupsError("Failed to load groups"));
    }
  }
}
