import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

enum RefreshType {
  groups,
  friends,
  activity,
  groupDetail,
  friendDetail,
  expenseDetail,
}

class RefreshSignal extends Equatable {
  final RefreshType type;
  final String? id;
  final DateTime timestamp;

  RefreshSignal(this.type, {this.id}) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [type, id, timestamp];
}

class DataRefreshState extends Equatable {
  final RefreshSignal? lastSignal;
  final Map<RefreshType, bool> globalFlags;
  final Map<RefreshType, Set<String>> idBasedFlags;

  const DataRefreshState({
    this.lastSignal,
    this.globalFlags = const {},
    this.idBasedFlags = const {},
  });

  DataRefreshState copyWith({
    RefreshSignal? lastSignal,
    Map<RefreshType, bool>? globalFlags,
    Map<RefreshType, Set<String>>? idBasedFlags,
  }) {
    return DataRefreshState(
      lastSignal: lastSignal ?? this.lastSignal,
      globalFlags: globalFlags ?? this.globalFlags,
      idBasedFlags: idBasedFlags ?? this.idBasedFlags,
    );
  }

  @override
  List<Object?> get props => [lastSignal, globalFlags, idBasedFlags];
}

class DataRefreshCubit extends Cubit<DataRefreshState> {
  DataRefreshCubit() : super(const DataRefreshState(
    globalFlags: {
      RefreshType.groups: false,
      RefreshType.friends: false,
      RefreshType.activity: false,
    },
    idBasedFlags: {
      RefreshType.groupDetail: <String>{},
      RefreshType.friendDetail: <String>{},
      RefreshType.expenseDetail: <String>{},
    },
  ));

  /// Marks a specific data type (and optionally an ID) as needing a refresh.
  void markForRefresh(RefreshType type, {String? id}) {
    final signal = RefreshSignal(type, id: id);
    
    if (id != null) {
      final newIdFlags = Map<RefreshType, Set<String>>.from(state.idBasedFlags);
      final newSet = Set<String>.from(newIdFlags[type] ?? {});
      newSet.add(id);
      newIdFlags[type] = newSet;
      emit(state.copyWith(lastSignal: signal, idBasedFlags: newIdFlags));
    } else {
      final newGlobalFlags = Map<RefreshType, bool>.from(state.globalFlags);
      newGlobalFlags[type] = true;
      emit(state.copyWith(lastSignal: signal, globalFlags: newGlobalFlags));
    }
  }

  /// Checks if a specific data type (and optionally an ID) needs a refresh.
  bool shouldRefresh(RefreshType type, {String? id}) {
    if (id != null) {
      return state.idBasedFlags[type]?.contains(id) ?? false;
    }
    return state.globalFlags[type] ?? false;
  }

  /// Clears the refresh flag for a specific data type (and optionally an ID).
  void clearRefresh(RefreshType type, {String? id}) {
    if (id != null) {
      final newIdFlags = Map<RefreshType, Set<String>>.from(state.idBasedFlags);
      final newSet = Set<String>.from(newIdFlags[type] ?? {});
      newSet.remove(id);
      newIdFlags[type] = newSet;
      emit(state.copyWith(idBasedFlags: newIdFlags));
    } else {
      final newGlobalFlags = Map<RefreshType, bool>.from(state.globalFlags);
      newGlobalFlags[type] = false;
      emit(state.copyWith(globalFlags: newGlobalFlags));
    }
  }

  /// Marks multiple types for refresh at once.
  void markMultipleForRefresh(List<RefreshType> types, {String? id}) {
    for (final type in types) {
      markForRefresh(type, id: id);
    }
  }
}
