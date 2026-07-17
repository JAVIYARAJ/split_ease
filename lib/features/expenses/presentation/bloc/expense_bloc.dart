import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_members.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/get_common_groups_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_participants_usecase.dart';
import 'package:split_ease/features/friends/domain/usecases/get_my_friends.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/create_expense_params.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/update_expense_params.dart';
import '../../domain/usecases/attach_expense_media_usecase.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_media_entity.dart';
import 'package:split_ease/core/services/cloudinary_upload_service.dart';
import 'dart:io';
import '../../domain/entities/expense_detail_entity.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_metadata_entity.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_metadata_usecase.dart';
import 'package:split_ease/core/usecases/use_case.dart';


part 'expense_event.dart';
part 'expense_state.dart';

/// The central logic coordinator for adding or editing an expense.
///
/// It manages the draft state including:
/// - Selecting the context (Group vs. Friend/Global).
/// - Fetching and managing split participants (Group members vs. selective friends).
/// - Handling diverse split types: equal, exact amounts, percentages, and shares.
/// - Validating and submitting the final expense payload to the server.
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpense updateExpenseUseCase;
  final GetGroupMembers getGroupMembers;
  final GetCommonGroupsUseCase getCommonGroupsUseCase;
  final GetExpenseParticipantsUsecase getExpenseParticipantsUsecase;
  final GetExpenseMetadataUseCase getExpenseMetadata;
  final GetMyFriends getMyFriends;
  final AttachExpenseMediaUseCase attachExpenseMediaUseCase;
  final DataRefreshCubit dataRefreshCubit;


  ExpenseBloc({
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.getGroupMembers,
    required this.getCommonGroupsUseCase,
    required this.getExpenseParticipantsUsecase,
    required this.getExpenseMetadata,
    required this.getMyFriends,
    required this.attachExpenseMediaUseCase,
    required this.dataRefreshCubit,
  }) : super(const ExpenseState()) {
    on<ExpenseInitialized>(_onInitialized);
    on<ExpenseEditInitialized>(_onEditInitialized);

    on<GroupChanged>(_onGroupChanged);
    on<FetchParticipants>(_onFetchParticipants);
    on<AmountChanged>(_onAmountChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<PayerChanged>(_onPayerChanged);
    on<DateChanged>(_onDateChanged);
    on<SplitTypeChanged>(_onSplitTypeChanged);
    on<SplitOptionChanged>(_onSplitOptionChanged);
    on<AddExpenseSubmitted>(_onAddExpenseSubmitted);
    on<FetchCommonGroups>(_onFetchCommonGroups);
    on<ValidateNavigation>(_onValidateNavigation);
    on<NotesChanged>(_onNotesChanged);
    on<FetchCategories>(_onFetchCategories);
    on<CategoryChanged>(_onCategoryChanged);
    on<PaymentMethodChanged>(_onPaymentMethodChanged);
    on<ExpenseOriginChanged>(_onExpenseOriginChanged);
    on<FetchAllFriendsForGlobalMode>(_onFetchAllFriendsForGlobalMode);
    on<AttachmentsChanged>(_onAttachmentsChanged);
  }

  void _onAttachmentsChanged(AttachmentsChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(attachments: event.attachments));
  }

  void _onExpenseOriginChanged(ExpenseOriginChanged event, Emitter<ExpenseState> emit) {
    if (event.origin == ExpenseOrigin.personal) {
      emit(state.copyWith(
        origin: event.origin,
        group: () => null,
        friend: () => null,
        splits: [],
        groupMembers: [],
        payerId: () => state.currentUserId,
      ));
    } else {
      // Switching back to shared/global
      emit(state.copyWith(
        origin: event.origin,
        payerId: () => state.currentUserId,
      ));
      // Re-fetch participants for self if no group/friend
      if (state.group == null && state.friend == null) {
        add(const FetchAllFriendsForGlobalMode());
      }
    }
  }

  Future<void> _onFetchCategories(FetchCategories event, Emitter<ExpenseState> emit) async {
    final result = await getExpenseMetadata();
    result.fold(
      (failure) => {}, // Handle error silently or show error
      (metadata) {
        ExpenseCategoryEntity? defaultCategory;
        try {
          if (event.lastUsedCategoryId != null) {
            defaultCategory = metadata.categories.firstWhere((c) => c.id == event.lastUsedCategoryId);
          }
        } catch (_) {}

        if (defaultCategory == null) {
          try {
            // Prioritize 'Other' category by name (allow variations like "Others"), fallback to isDefault
            defaultCategory = metadata.categories.firstWhere((c) => c.name.toLowerCase().contains('other'), 
              orElse: () => metadata.categories.firstWhere((c) => c.isDefault));
          } catch (_) {
            if (metadata.categories.isNotEmpty) defaultCategory = metadata.categories.first;
          }
        }

        ExpensePaymentMethodEntity? defaultPaymentMethod;
        try {
          defaultPaymentMethod = metadata.paymentMethods.firstWhere((pm) => pm.name.toLowerCase().contains('cash'));
        } catch (_) {
          if (metadata.paymentMethods.isNotEmpty) defaultPaymentMethod = metadata.paymentMethods.first;
        }

        emit(state.copyWith(
          categories: metadata.categories,
          selectedCategory: () => state.selectedCategory ?? defaultCategory,
          paymentMethods: metadata.paymentMethods,
          selectedPaymentMethod: () => state.selectedPaymentMethod ?? defaultPaymentMethod,
        ));
      },
    );
  }

  void _onCategoryChanged(CategoryChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(selectedCategory: () => event.category));
  }

  void _onPaymentMethodChanged(PaymentMethodChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(selectedPaymentMethod: () => event.paymentMethod));
  }

  /// Logic Moved from UI: Validates basic form requirements before allowing navigation
  /// to secondary selection screens (Payer/Split).
  void _onValidateNavigation(ValidateNavigation event, Emitter<ExpenseState> emit) {
    if (state.isBaseInfoValid) {
      event.onValid();
    } else {
      emit(state.copyWith(
        status: ExpenseStatus.validationError,
        errorMessage: () => state.baseInfoValidationError,
      ));
      // Reset status to initial to allow subsequent attempts
      emit(state.copyWith(status: ExpenseStatus.initial));
    }
  }

  /// Sets up the initial state when the page is first opened.
  /// 
  /// It automatically triggers participant fetching based on the initial context
  /// provided (group or friend). It also initializes the date to today and
  /// sets the current user as the default payer.
  void _onInitialized(ExpenseInitialized event, Emitter<ExpenseState> emit) {
    emit(ExpenseState(
      group: event.group,
      friend: event.friend,
      payerId: event.currentUserId,
      currentUserId: event.currentUserId,
      date: DateTime.now(),
      origin: event.origin,
    ));


    // Determine initial participants immediately
    if (event.group?.id != null) {
      // If we already have members in the group entity, use them to avoid a redundant RPC call
      if (event.group!.members != null && event.group!.members!.isNotEmpty) {
        final members = event.group!.members!;
        _initializeSplitsWithMembers(members, emit);
      } else {
        add(FetchParticipants(groupId: event.group!.id!));
      }
    } else if (event.friend != null) {
      // For single-friend context, we fetch participants (usually current user + friend)
      add(FetchParticipants(friendUserId: event.friend!.id));
    } else if (event.origin == ExpenseOrigin.global) {
      add(const FetchAllFriendsForGlobalMode());
    }
    
    if (event.currentUserId != null) {
      final userIds = event.friend != null 
          ? [event.currentUserId!, event.friend!.id] 
          : [event.currentUserId!];
      add(FetchCommonGroups(userIds));
    }
    
    add(FetchCategories(lastUsedCategoryId: event.lastUsedCategoryId));
  }

  /// Updates the state when the user selects a group from the picker.
  /// 
  /// Switching to a group context usually resets the participant list and 
  /// triggers a fetch for that specific group's members.
  void _onGroupChanged(GroupChanged event, Emitter<ExpenseState> emit) {
    // Avoid redundant updates
    if (event.group?.id == state.group?.id) return;

    if (event.group == null) {
      // User chose "Non-group" (or cleared the group)
      emit(state.clearGroup().copyWith(payerId: () => state.currentUserId));
      
      // Always fetch participants. If friend is null, it fetches 'Self'.
      add(FetchParticipants(friendUserId: state.friend?.id));
    } else {
      // User selected a specific group. 
      // Reset payerId to current user instead of null to avoid the "select payer" exception
      // if the current user is expected to be in the group.
      emit(state.toGroupMode(event.group!).copyWith(payerId: () => state.currentUserId));

      
      // Fetch fresh member list for the new group
      if (event.group?.id != null) {
        add(FetchParticipants(groupId: event.group!.id));
      }
    }
  }

  /// Unified participant fetcher for both group and friend contexts.
  /// 
  /// It populates [groupMembers] and automatically creates a [splits] entry 
  /// for every participant, defaulting to an equal split.
  Future<void> _onFetchParticipants(FetchParticipants event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(groupMembersStatus: ExpenseStatus.loading));
    
    final result = await getExpenseParticipantsUsecase(GetExpenseParticipantsParams(
      groupId: event.groupId,
      friendUserId: event.friendUserId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        groupMembersStatus: ExpenseStatus.failure,
        errorMessage: () => failure.message,
      )),
      (participants) {
        // Transform the domain user entity into the member format used by the UI
        final members = participants.map((p) => GroupMemberEntity(
          userId: p.id,
          fullName: p.fullName,
          email: '', 
          role: 'member',
          avtar: p.avatar ?? '',
        )).toList();
        
        _initializeSplitsWithMembers(members, emit);
      },
    );
  }

  Future<void> _onFetchAllFriendsForGlobalMode(FetchAllFriendsForGlobalMode event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(groupMembersStatus: ExpenseStatus.loading));
    
    final result = await getMyFriends(NoParams());
    
    result.fold(
      (failure) {
        final members = <GroupMemberEntity>[];
        if (state.currentUserId != null) {
          members.add(GroupMemberEntity(
            userId: state.currentUserId,
            fullName: state.payerName ?? "You",
            email: '',
            role: 'member',
            
          ));
        }
        emit(state.copyWith(
          groupMembersStatus: ExpenseStatus.failure,
          errorMessage: () => failure.message,
        ));
        _initializeSplitsWithMembers(members, emit);
      },
      (friends) {
        final members = friends.map((f) => GroupMemberEntity(
          userId: f.id,
          fullName: f.name,
          email: f.email ?? '',
          avtar: f.imageUrl ?? '',
          role: 'member',
          
        )).toList();
        
        if (state.currentUserId != null && !members.any((m) => m.userId == state.currentUserId)) {
          members.insert(0, GroupMemberEntity(
            userId: state.currentUserId,
            fullName: state.payerName ?? "You",
            email: '',
            role: 'member',
            
          ));
        }

        _initializeSplitsWithMembers(members, emit);
      }
    );
  }

  /// Internal helper to initialize the split list once participants are known.
  void _initializeSplitsWithMembers(List<GroupMemberEntity> members, Emitter<ExpenseState> emit) {
    if (state.isEdit && state.splits.isNotEmpty) {
      // In Edit mode, if we already have a splits list (from the initial load),
      // we prioritize it. We only update the group members list.
      emit(state.copyWith(
        groupMembersStatus: ExpenseStatus.success,
        groupMembers: members,
      ));
    } else {
      // For NEW expenses, or if we switched context (clearing the splits), 
      // we default to including all members in the split, EXCEPT in global mode
      // where we only want to include the current user initially to prevent accidentally
      // splitting with all friends.
      List<ExpenseSplit> initialSplits;
      if (state.origin == ExpenseOrigin.global && state.group == null && state.friend == null) {
        initialSplits = members
            .where((m) => m.userId == state.currentUserId)
            .map((m) => ExpenseSplit(
              userId: m.userId!,
              amount: 0,
              percentage: 0,
              shares: 1,
            )).toList();
        
        if (initialSplits.isEmpty && members.isNotEmpty) {
          initialSplits = [ExpenseSplit(
            userId: members.first.userId!,
            amount: 0,
            percentage: 0,
            shares: 1,
          )];
        }
      } else {
        initialSplits = members.map((m) => ExpenseSplit(
          userId: m.userId!,
          amount: 0,
          percentage: 0,
          shares: 1,
        )).toList();
      }

      emit(state.copyWith(
        groupMembersStatus: ExpenseStatus.success,
        groupMembers: members,
        splits: initialSplits,
      ));
    }
  }




  /// Fetches shared groups in the background when in friend-entry mode.
  Future<void> _onFetchCommonGroups(FetchCommonGroups event, Emitter<ExpenseState> emit) async {
    final result = await getCommonGroupsUseCase(event.userIds);
    result.fold(
      (failure) => {}, // Silently handle common groups fetch failure
      (groups) => emit(state.copyWith(commonGroups: groups)),
    );
  }

  // ── Simple state updates for form fields ────────────────────────────────────

  void _onAmountChanged(AmountChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onDescriptionChanged(DescriptionChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onPayerChanged(PayerChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(payerId: () => event.userId));
  }

  void _onDateChanged(DateChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onSplitTypeChanged(SplitTypeChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(splitType: event.splitType));
  }

  void _onSplitOptionChanged(SplitOptionChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(splits: event.splits));
  }

  void _onNotesChanged(NotesChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  // ── Submission Logic ────────────────────────────────────────────────────────

  /// Finalizes the draft and sends it to the backend.
  Future<void> _onAddExpenseSubmitted(AddExpenseSubmitted event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    
    try {
      // 1. Validation
      if (state.description.trim().isEmpty) {
        throw Exception("Please enter a description for the expense.");
      }

      final amountVal = double.tryParse(state.amount) ?? 0;
      if (state.amount.isEmpty || amountVal <= 0) {
        throw Exception("Please enter a valid amount greater than 0.");
      }

      if (state.selectedCategory == null) {
        throw Exception("Please select an expense category.");
      }

      if (state.selectedPaymentMethod == null) {
        throw Exception("Please select a payment method.");
      }

      final finalPayerId = state.payerId ?? state.currentUserId;
      if (state.origin != ExpenseOrigin.personal && finalPayerId == null) {
        throw Exception("Please select who paid.");
      }

      // 2. Format splits for the RPC
      final List<Map<String, dynamic>> rpcSplits = [];
      for (var split in state.splits) {
        final Map<String, dynamic> entry = {'user_id': split.userId};
        bool isParticipant = true;
        
        switch (state.splitType) {
          case SplitType.equal:
            // In equal mode, the list existence itself defines participation
            break;
          case SplitType.exact:
            entry['amount'] = split.amount;
            if (split.amount <= 0) isParticipant = false;
            break;
          case SplitType.percentage:
            entry['value'] = split.percentage;
            if (split.percentage <= 0) isParticipant = false;
            break;
          case SplitType.shares:
            entry['value'] = split.shares;
            if (split.shares <= 0) isParticipant = false;
            break;
        }
        
        if (isParticipant) {
           rpcSplits.add(entry);
        }
      }


      final splitTypeName = state.splitType == SplitType.shares ? 'share' : state.splitType.name;
      
      // Post-split formatting validation for Global mode
      if (!state.isEdit && state.origin != ExpenseOrigin.personal && state.group == null && state.friend == null) {
         final hasOtherParticipants = rpcSplits.any((s) => s['user_id'] != state.currentUserId);
         if (!hasOtherParticipants) {
            throw Exception("Please select friends to split with or switch to Personal mode.");
         }
      }

      if (state.isEdit && state.expenseId != null) {
        // Determine scope
        String expenseScope = 'non_group';
        if (state.origin == ExpenseOrigin.personal) {
          expenseScope = 'personal';
        } else if (state.group?.id != null) {
          expenseScope = 'group';
        }

        // Handle Update
        final params = UpdateExpenseParams(
          expenseId: state.expenseId!,
          description: state.description.isEmpty ? "No description" : state.description,
          notes: state.notes,
          categoryId: state.selectedCategory?.id,
          paymentMethodId: state.selectedPaymentMethod?.id,
          totalAmount: double.parse(state.amount),
          paidByUserId: finalPayerId ?? '',
          expenseDate: state.date ?? DateTime.now(),
          splitType: splitTypeName,
          splits: rpcSplits,
          groupId: state.group?.id,
          expenseScope: expenseScope,
        );

        final result = await updateExpenseUseCase(params);
        await result.fold(
          (failure) async => emit(state.copyWith(status: ExpenseStatus.failure, errorMessage: () => failure.message)),
          (_) async {
            if (state.attachments.isNotEmpty) {
              try {
                final mediaList = await Future.wait(
                  state.attachments.map((path) => CloudinaryUploadService.uploadFile(File(path)))
                );
                await attachExpenseMediaUseCase(AttachExpenseMediaParams(
                  expenseId: state.expenseId!, 
                  media: mediaList,
                ));
              } catch (e) {
                // Non-fatal error, expense is already updated
              }
            }

            dataRefreshCubit.markMultipleForRefresh([
              RefreshType.home,
              RefreshType.groups,
              RefreshType.friends,
              RefreshType.activity,
            ]);
            if (state.group?.id != null) {
              dataRefreshCubit.markForRefresh(RefreshType.groupDetail, id: state.group!.id);
            }
            if (state.friend?.id != null) {
              dataRefreshCubit.markForRefresh(RefreshType.friendDetail, id: state.friend!.id);
            }
            dataRefreshCubit.markForRefresh(RefreshType.expenseDetail, id: state.expenseId);
            
            emit(state.copyWith(status: ExpenseStatus.success));
          },
        );
      } else {
        // Determine scope
        String expenseScope = 'non_group';
        if (state.origin == ExpenseOrigin.personal) {
          expenseScope = 'personal';
        } else if (state.group != null) {
          expenseScope = 'group';
        }

        // Handle Create
        final params = CreateExpenseParams(
          expenseScope: expenseScope,
          groupId: state.group?.id,
          description: state.description.isEmpty ? "No description" : state.description,
          notes: state.notes,
          categoryId: state.selectedCategory?.id,
          paymentMethodId: state.selectedPaymentMethod?.id,
          totalAmount: double.parse(state.amount),
          paidByUserId: state.origin == ExpenseOrigin.personal ? null : finalPayerId,
          expenseDate: state.date ?? DateTime.now(),
          splitType: state.origin == ExpenseOrigin.personal ? null : splitTypeName,
          splits: state.origin == ExpenseOrigin.personal ? null : rpcSplits,
        );

        final result = await addExpenseUseCase(params);
        await result.fold(
          (failure) async => emit(state.copyWith(status: ExpenseStatus.failure, errorMessage: () => failure.message)),
          (expenseId) async {
            if (state.attachments.isNotEmpty) {
              try {
                final mediaList = await Future.wait(
                  state.attachments.map((path) => CloudinaryUploadService.uploadFile(File(path)))
                );
                await attachExpenseMediaUseCase(AttachExpenseMediaParams(
                  expenseId: expenseId, 
                  media: mediaList,
                ));
              } catch (e) {
                // Non-fatal error
              }
            }

            dataRefreshCubit.markMultipleForRefresh([
              RefreshType.home,
              RefreshType.groups,
              RefreshType.friends,
              RefreshType.activity,
            ]);
            if (state.group?.id != null) {
              dataRefreshCubit.markForRefresh(RefreshType.groupDetail, id: state.group!.id);
            }
            if (state.friend?.id != null) {
              dataRefreshCubit.markForRefresh(RefreshType.friendDetail, id: state.friend!.id);
            }
            emit(state.copyWith(status: ExpenseStatus.success));
          },
        );
      }
    } catch (e) {
      // Extract just the message without "Exception: " if it exists
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring(11); // Length of "Exception: "
      }
      emit(state.copyWith(status: ExpenseStatus.validationError, errorMessage: () => errorMessage));
      // Reset status to initial to allow subsequent attempts
      emit(state.copyWith(status: ExpenseStatus.initial));
    }
  }

  void _onEditInitialized(ExpenseEditInitialized event, Emitter<ExpenseState> emit) {
    final expense = event.expense;
    
    // Parse expense type to SplitType
    SplitType type = SplitType.equal;
    if (expense.expenseType == 'exact') {
      type = SplitType.exact;
    } else if (expense.expenseType == 'percentage'){
      type = SplitType.percentage;
    } else if (expense.expenseType == 'share') {
      type = SplitType.shares;
    }

    // Transform splits and attempt to recover percentages if needed
    final List<ExpenseSplit> initialSplits = expense.splits.map((s) {
      double percentage = 0;
      if (type == SplitType.percentage && expense.totalAmount > 0) {
        percentage = (s.amount / expense.totalAmount) * 100;
      }
      
      return ExpenseSplit(
        userId: s.userId,
        amount: s.amount,
        percentage: percentage,
        shares: 1, // Defaulting as RPC doesn't return raw shares
      );
    }).toList();

    // Transform participants to members (initial list)
    final List<GroupMemberEntity> members = expense.splits.map((s) => GroupMemberEntity(
      userId: s.userId,
      fullName: s.fullName,
      email: '',
      role: 'member',
      avtar: s.avatar ?? '',
    )).toList();

    // Ensure payer is in members list so their name displays correctly immediately
    if (!members.any((m) => m.userId == expense.paidBy.id)) {
      members.add(GroupMemberEntity(
        userId: expense.paidBy.id,
        fullName: expense.paidBy.fullName,
        email: '',
        role: 'member',
        avtar: expense.paidBy.avatar ?? '',
      ));
    }

    FriendEntity? friend;
    ExpenseOrigin origin = ExpenseOrigin.group;

    if (expense.group != null && expense.group?.id != null) {
      origin = ExpenseOrigin.group;
    } else if (expense.splits.isEmpty) {
      origin = ExpenseOrigin.personal;
    } else {
      origin = ExpenseOrigin.friend;
      ExpenseSplitEntity? otherSplit;
      for (var s in expense.splits) {
        if (s.userId != event.currentUserId) {
          otherSplit = s;
          break;
        }
      }
      otherSplit ??= expense.splits.first;

      friend = FriendEntity(
        id: otherSplit.userId,
        name: otherSplit.fullName,
        email: '',
        imageUrl: otherSplit.avatar,
        overallBalance: 0,
        nonGroupBalance: 0,
        totalBalanceGroups: 0,
        status: 'accepted',
        groupBreakdown: const [],
      );
    }

    emit(state.copyWith(
      expenseId: () => expense.id,
      isEdit: true,
      description: expense.description,
      amount: (expense.totalAmount % 1 == 0) 
          ? expense.totalAmount.toInt().toString() 
          : expense.totalAmount.toString(),
      payerId: () => expense.paidBy.id,
      currentUserId: event.currentUserId,
      date: DateTime.tryParse(expense.expenseDate) ?? DateTime.now(),
      splitType: type,
      splits: initialSplits,
      groupMembers: members,
      groupMembersStatus: ExpenseStatus.success,
      group: () => (expense.group != null && expense.group?.id != null) ? GroupEntity(id: expense.group!.id!, name: expense.group!.name ?? '', groupIcon: expense.group!.groupIcon) : null,
      friend: () => friend,
      notes: expense.notes ?? '',
      origin: origin,
      selectedCategory: () => expense.category,
      selectedPaymentMethod: () => expense.paymentMethod,
      existingMedia: expense.media,
    ));




    // 3. Background background data fetching
    if (expense.group?.id != null) {
       add(FetchParticipants(groupId: expense.group!.id!));
    } else {
       // For non-group expenses, fetch common groups between user and friend 
       // to allow converting it to a group expense.
       if (friend != null) {
          add(FetchCommonGroups([event.currentUserId, friend.id]));
       }
    }

    add(const FetchCategories());
  }

}
