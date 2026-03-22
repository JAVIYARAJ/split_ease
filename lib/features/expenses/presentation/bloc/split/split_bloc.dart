import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

part 'split_event.dart';
part 'split_state.dart';

class SplitBloc extends Bloc<SplitEvent, SplitState> {
  /// Logic Coordinator for the Split Options Page.
  /// 
  /// This Bloc manages:
  /// - Initialization of splits for provided members.
  /// - Updates to split values (exact, percentage, shares).
  /// - Automatic recalculation of 'equal' split amounts.
  SplitBloc() : super(const SplitState()) {
    on<InitializeSplitEvent>(_onInitializeSplit);
    on<UpdateSplitTypeEvent>(_onUpdateSplitType);
    on<UpdateSplitAmountEvent>(_onUpdateSplitAmount);
    on<UpdateSplitPercentageEvent>(_onUpdateSplitPercentage);
    on<UpdateSplitSharesEvent>(_onUpdateSplitShares);
    on<ToggleAllSelectionEvent>(_onToggleAllSelection);
    on<ToggleMemberSelectionEvent>(_onToggleMemberSelection);
  }

  /// Initializes the split list. Logic Moved from UI: Default shares and 
  /// base split entries are now handled here.
  void _onInitializeSplit(InitializeSplitEvent event, Emitter<SplitState> emit) {
    List<ExpenseSplit> currentSplits;
    if (event.initialSplits.isNotEmpty) {
      currentSplits = List.from(event.initialSplits);
    } else {
      currentSplits = event.members.map((member) {
        return ExpenseSplit(
          userId: member.userId!,
          amount: 0.0,
          percentage: 0.0,
          shares: 1.0,
        );
      }).toList();
    }
    
    emit(state.copyWith(
      members: event.members,
      splitType: event.initialSplitType,
      splits: currentSplits,
      totalAmount: event.totalAmount,
    ));
    
    // Ensure splits are consistent with members if needed
    _ensureSplitsExistForMembers(emit);
  }

  void _onUpdateSplitType(UpdateSplitTypeEvent event, Emitter<SplitState> emit) {
    emit(state.copyWith(splitType: event.splitType));
    _ensureSplitsExistForMembers(emit);
  }

  void _ensureSplitsExistForMembers(Emitter<SplitState> emit) {
    // In EQUAL mode, the splits list acts as a set of SELECTED members. 
    // We should NOT auto-add members who aren't in the list, as that would 
    // select them by default. For other modes, we want everyone in the list 
    // to allow entering amounts/percentages.
    if (state.splitType == SplitType.equal) {
      return;
    }

    final currentSplits = List<ExpenseSplit>.from(state.splits);
    final setOfCurrent = currentSplits.map((s) => s.userId).toSet();
    
    bool changed = false;
    for (var member in state.members) {
      if (!setOfCurrent.contains(member.userId)) {
        currentSplits.add(ExpenseSplit(
          userId: member.userId!,
          amount: 0,
          percentage: 0,
          shares: 1,
        ));
        changed = true;
      }
    }
    
    if (changed) {
      emit(state.copyWith(splits: currentSplits));
    }
  }


  void _onUpdateSplitAmount(UpdateSplitAmountEvent event, Emitter<SplitState> emit) {
     final index = state.splits.indexWhere((s) => s.userId == event.userId);
     if (index != -1) {
       final newSplits = List<ExpenseSplit>.from(state.splits);
       newSplits[index] = newSplits[index].copyWith(amount: event.amount);
       emit(state.copyWith(splits: newSplits));
     }
  }

  void _onUpdateSplitPercentage(UpdateSplitPercentageEvent event, Emitter<SplitState> emit) {
    final index = state.splits.indexWhere((s) => s.userId == event.userId);
    if (index != -1) {
      final newSplits = List<ExpenseSplit>.from(state.splits);
      newSplits[index] = newSplits[index].copyWith(percentage: event.percentage);
      emit(state.copyWith(splits: newSplits));
    }
  }

  void _onUpdateSplitShares(UpdateSplitSharesEvent event, Emitter<SplitState> emit) {
    final index = state.splits.indexWhere((s) => s.userId == event.userId);
    if (index != -1) {
      final newSplits = List<ExpenseSplit>.from(state.splits);
      newSplits[index] = newSplits[index].copyWith(shares: event.shares);
      emit(state.copyWith(splits: newSplits));
    }
  }

  void _onToggleAllSelection(ToggleAllSelectionEvent event, Emitter<SplitState> emit) {
    if (state.splitType == SplitType.equal) {
       List<ExpenseSplit> newSplits;
       if (state.splits.length == state.members.length) {
         newSplits = []; // Deselect all
       } else {
         newSplits = state.members.map((m) => ExpenseSplit(
           userId: m.userId!,
           amount: 0,
           percentage: 0,
           shares: 1,
         )).toList(); // Select all
       }
       
       if (newSplits.isNotEmpty) {
         final amountPerPerson = state.totalAmount / newSplits.length;
         newSplits = newSplits.map((s) => s.copyWith(amount: amountPerPerson)).toList();
       }

       emit(state.copyWith(splits: newSplits));
    }
  }

  void _onToggleMemberSelection(ToggleMemberSelectionEvent event, Emitter<SplitState> emit) {
    if (state.splitType == SplitType.equal) {
      final currentSplits = List<ExpenseSplit>.from(state.splits);
      final index = currentSplits.indexWhere((s) => s.userId == event.userId);

      if (index != -1) {
        // Deselect
        currentSplits.removeAt(index);
      } else {
        // Select
        // Find the member entity to get correct details if needed, though userId is enough for split
        currentSplits.add(ExpenseSplit(
          userId: event.userId,
          amount: 0,
          percentage: 0,
          shares: 1,
        ));
      }
      
      // Recalculate amounts
      if (currentSplits.isNotEmpty) {
        final amountPerPerson = state.totalAmount / currentSplits.length;
        for (int i = 0; i < currentSplits.length; i++) {
          currentSplits[i] = currentSplits[i].copyWith(amount: amountPerPerson);
        }
      }
      
      emit(state.copyWith(splits: currentSplits));
    }
  }
}
