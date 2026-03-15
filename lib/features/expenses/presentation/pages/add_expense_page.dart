import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/presentation/widgets/group_picker_sheet.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/groups/data/models/group_member_model.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      final appUserState = context.read<AppUserCubit>().state;
      String? currentUserId;
      if (appUserState is AppUserLoggedIn) {
        currentUserId = appUserState.user.id;
      }

      // Three modes: Group Mode, Friend Mode, or Blank Mode
      final GroupEntity? group = args?['group'] as GroupEntity?;
      final FriendEntity? friend = args?['friend'] as FriendEntity?;
      final List<GroupEntity> availableGroups =
          (args?['groups'] as List?)?.cast<GroupEntity>() ?? [];

      context.read<ExpenseBloc>().add(ExpenseInitialized(
        group: group,
        friend: friend,
        availableGroups: availableGroups,
        currentUserId: currentUserId,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.openSans(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          "Add expense",
          style: GoogleFonts.openSans(color: AppColors.textBlack, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              if (state.status == ExpenseStatus.loading) {
                 return const Padding(
                   padding: EdgeInsets.only(right: 16.0),
                   child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal))),
                 );
              }
              return TextButton(
                onPressed: () => _onSave(context, state),
                child: Text(
                  "Save",
                  style: GoogleFonts.openSans(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state.status == ExpenseStatus.success) {
            AppAlerts.showSuccess(context, 'Expense added successfully!');
            Navigator.pop(context, true);
          } else if (state.status == ExpenseStatus.failure) {
            AppAlerts.showError(context, state.errorMessage ?? 'Failed to add expense');
          }
        },
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state.status == ExpenseStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final group = state.group;
            final friend = state.friend;

            // Members for split/payer:
            // - Group mode: use group members
            // - Friend mode (no group): synthetic 2-member list [you, friend]
            // - Blank mode: empty
            final appUserState = context.read<AppUserCubit>().state;
            final currentUser = appUserState is AppUserLoggedIn ? appUserState.user : null;

            List<GroupMemberEntity> members;
            if (group != null) {
              // Group mode: use group members fetched from RPC
              members = state.groupMembers;
            } else if (friend != null && currentUser != null) {
              // 2-member synthetic list for a 1-on-1 friend expense (no group context yet)
              members = [
                GroupMemberEntity(
                  memberId: currentUser.id,
                  userId: currentUser.id,
                  fullName: 'You (${currentUser.name})',
                  email: currentUser.email,
                  role: 'member',
                  joinedAt: '',
                  avtar: currentUser.avatarUrl ?? '',
                ),
                GroupMemberEntity(
                  memberId: friend.id,
                  userId: friend.id,
                  fullName: friend.name,
                  email: friend.email ?? '',
                  role: 'member',
                  joinedAt: '',
                  avtar: friend.imageUrl ?? '',
                ),
              ];
            } else {
              members = [];
            }

            final payerName = state.payerId != null && members.isNotEmpty
                ? members
                      .firstWhere(
                        (m) => m.userId == state.payerId,
                        orElse: () => const GroupMemberModel(memberId: '', userId: '', fullName: 'you', email: '', role: '', joinedAt: '', avtar: ''),
                      )
                      .fullName
                : "you";

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // ── Context Badge ──
                  if (group != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: group.groupIcon != null
                                  ? DecorationImage(image: CachedNetworkImageProvider(group.groupIcon!), fit: BoxFit.cover)
                                  : null,
                              color: group.groupIcon == null ? AppColors.primaryTeal : null,
                            ),
                            child: group.groupIcon == null ? const Icon(Icons.group, color: Colors.white, size: 14) : null,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "With you and: ${group.name ?? "Group"}",
                              style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (friend != null)
                    GestureDetector(
                      onTap: () async {
                        final g = await showGroupPickerFromList(context, state.availableGroups);
                        if (g != null && context.mounted) {
                          context.read<ExpenseBloc>().add(GroupChanged(g));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.backgroundLightGrey,
                                image: friend.imageUrl != null
                                    ? DecorationImage(image: CachedNetworkImageProvider(friend.imageUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: friend.imageUrl == null ? const Icon(Icons.person, color: AppColors.textGrey, size: 16) : null,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "With you and: ${friend.name}",
                                style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 16, color: AppColors.textGrey),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () async {
                        final g = await showGroupPickerFromList(context, state.availableGroups);
                        if (g != null && context.mounted) {
                          context.read<ExpenseBloc>().add(GroupChanged(g));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_outlined, size: 18, color: AppColors.textGrey),
                            const SizedBox(width: 6),
                            Text(
                              "No group · tap to select",
                              style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textGrey),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 16, color: AppColors.textGrey),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Description Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderGrey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long_outlined, color: AppColors.textGrey, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Enter a description",
                              hintStyle: GoogleFonts.openSans(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w500),
                            onChanged: (value) => context.read<ExpenseBloc>().add(DescriptionChanged(value)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Amount Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.currency_rupee, color: AppColors.textBlack, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: "0.00",
                              hintStyle: GoogleFonts.openSans(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.openSans(fontSize: 32, fontWeight: FontWeight.bold),
                            onChanged: (value) => context.read<ExpenseBloc>().add(AmountChanged(value)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Paid by / Split section — shown when group is set OR friend is set (2 members)
                  // Note: group from GroupsPage list may have no members loaded, so check group != null too
                  if (group != null || members.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Paid By Row
                            InkWell(
                              onTap: () async {
                                final result = await NavigationService.pushNamed(
                                  AppRoutes.payerSelection,
                                  args: {
                                     'members': members,
                                     'currentPayerId': state.payerId,
                                   }
                                );
                                if (result != null && result is String) {
                                   if(context.mounted) {
                                     context.read<ExpenseBloc>().add(PayerChanged(result));
                                   }
                                }
                              },
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.person_outline, color: AppColors.primaryTeal, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text("Paid by", style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textBlack)),
                                    const Spacer(),
                                    Text(
                                      payerName ?? "you", 
                                      style: GoogleFonts.openSans(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryTeal)
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right, size: 18, color: AppColors.textGrey),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.borderGrey, indent: 16, endIndent: 16),
                            // Split Row
                            InkWell(
                              onTap: () async {
                                final result = await NavigationService.pushNamed(
                                  AppRoutes.splitOptions,
                                  args: {
                                    'members': members,
                                    'splitType': state.splitType,
                                    'splits': state.splits,
                                    'totalAmount': double.tryParse(state.amount) ?? 0.0,
                                  }
                                );
                                if (result != null && result is Map<String, dynamic>) {
                                  if (context.mounted) {
                                    context.read<ExpenseBloc>().add(SplitTypeChanged(result['splitType']));
                                    context.read<ExpenseBloc>().add(SplitOptionChanged(result['splits']));
                                  }
                                }
                              },
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.call_split_outlined, color: AppColors.primaryTeal, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text("Split", style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textBlack)),
                                    const Spacer(),
                                    Text(
                                      state.splitType == SplitType.equal
                                          ? (state.splits.length == members.length ? "equally" : "equally (${state.splits.length})")
                                          : "unequally",
                                      style: GoogleFonts.openSans(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryTeal),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right, size: 18, color: AppColors.textGrey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Date Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onTap: () async {
                        final result = await NavigationService.pushNamed(
                          AppRoutes.dateSelection,
                          args: {
                            'initialDate': state.date
                          },
                        );
                        if (result != null && result is DateTime) {
                          if (context.mounted) {
                             context.read<ExpenseBloc>().add(DateChanged(result));
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: AppColors.textGrey),
                          const SizedBox(width: 8),
                          BlocBuilder<ExpenseBloc, ExpenseState>(
                            builder: (context, s) {
                              return Text(
                                s.date != null
                                    ? DateFormat('MMMM d, yyyy').format(s.date!)
                                    : "Today",
                                style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  void _onSave(BuildContext context, ExpenseState state) {
    if (state.description.isEmpty) {
      AppAlerts.showError(context, "Please enter description");
      return;
    }
    if (state.amount.isEmpty) {
      AppAlerts.showError(context, "Please enter amount");
      return;
    }
    if (state.group?.id == null) {
      AppAlerts.showError(context, "Please select a group to split the expense");
      return;
    }
    if (state.groupMembers.length <= 1) {
      AppAlerts.showError(context, "You need at least one other member in the group to add an expense.");
      return;
    }
    context.read<ExpenseBloc>().add(AddExpenseSubmitted(groupId: state.group!.id!));
  }
}
