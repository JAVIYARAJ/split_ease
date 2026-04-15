import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/group_picker_sheet.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/core/config/app_configs.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_bloc.dart';

import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

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

      // Modes: Group Mode, Friend Mode, or Global Mode
      final GroupEntity? group = args?['group'] as GroupEntity?;
      final FriendEntity? friend = args?['friend'] as FriendEntity?;
      final ExpenseDetailEntity? expense = args?['expense'] as ExpenseDetailEntity?;

      if (expense != null) {
        // Always pre-fill text fields first
        _descriptionController.text = expense.description;
        _amountController.text = (expense.totalAmount % 1 == 0) 
            ? expense.totalAmount.toInt().toString() 
            : expense.totalAmount.toString();

        if (currentUserId != null) {
          context.read<ExpenseBloc>().add(ExpenseEditInitialized(
            expense: expense,
            currentUserId: currentUserId,
          ));
        }
      } else {


        // Determine origin
        ExpenseOrigin origin = ExpenseOrigin.global;
        if (args?['origin'] != null && args?['origin'] is ExpenseOrigin) {
          origin = args?['origin'] as ExpenseOrigin;
        } else if (group != null) {
          origin = ExpenseOrigin.group;
        } else if (friend != null) {
          origin = ExpenseOrigin.friend;
        }
        
        context.read<ExpenseBloc>().add(ExpenseInitialized(
          group: group,
          friend: friend,
          currentUserId: currentUserId,
          origin: origin,
        ));
      }
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
        title: BlocBuilder<ExpenseBloc, ExpenseState>(
          buildWhen: (previous, current) => previous.isEdit != current.isEdit,
          builder: (context, state) {
            return Text(
              state.isEdit ? "Edit expense" : "Add expense",
              style: GoogleFonts.openSans(color: AppColors.textBlack, fontWeight: FontWeight.w600, fontSize: 18),
            );
          },
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
            AppAlerts.showSuccess(context, state.isEdit ? 'Expense updated successfully!' : 'Expense added successfully!');
            Navigator.pop(context, true);
          } else if (state.status == ExpenseStatus.failure || state.status == ExpenseStatus.validationError) {
            AppAlerts.showError(context, state.errorMessage ?? 'An error occurred');
          }
        },

        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {

            final group = state.group;
            final friend = state.friend;

            final members = state.groupMembers;
            final payerName = state.payerName;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Context Badge moved or simplified
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
                              "In: ${group.name ?? "Non-group"}",
                              style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (friend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppAvatar(
                            url: friend.imageUrl,
                            radius: 12,
                            backgroundColor: AppColors.backgroundLightGrey,
                            iconColor: AppColors.textGrey,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "With: ${friend.name}",
                              style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                            controller: _descriptionController,
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
                            controller: _amountController,
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

                  // Paid by / Split section
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
                          // 1. Payer & Split (Primary Logic)
                          Skeletonizer(
                            enabled: state.groupMembersStatus == ExpenseStatus.loading,
                            child: Column(
                              children: [
                                // Paid By Row
                                InkWell(
                                  onTap: state.groupMembersStatus == ExpenseStatus.loading 
                                    ? null 
                                    : () {
                                      context.read<ExpenseBloc>().add(ValidateNavigation(
                                        onValid: () async {
                                          final result = await NavigationService.pushNamed(
                                            AppRoutes.payerSelection,
                                            args: {
                                              'members': members,
                                              'currentPayerId': state.payerId,
                                            },
                                          );
                                          if (result != null && result is String) {
                                            if (context.mounted) {
                                              context.read<ExpenseBloc>().add(PayerChanged(result));
                                            }
                                          }
                                        },
                                      ));
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
                                  onTap: state.groupMembersStatus == ExpenseStatus.loading 
                                    ? null 
                                    : () {
                                      context.read<ExpenseBloc>().add(ValidateNavigation(
                                        onValid: () async {
                                          final result = await NavigationService.pushNamed(
                                            AppRoutes.splitOptions,
                                            args: {
                                              'members': members,
                                              'splitType': state.splitType,
                                              'splits': state.splits,
                                              'totalAmount': double.tryParse(state.amount) ?? 0.0,
                                            },
                                          );
                                          if (result != null && result is Map<String, dynamic>) {
                                            if (context.mounted) {
                                              context.read<ExpenseBloc>().add(SplitTypeChanged(result['splitType']));
                                              context.read<ExpenseBloc>().add(SplitOptionChanged(result['splits']));
                                            }
                                          }
                                        },
                                      ));
                                    },
                                  borderRadius: state.origin == ExpenseOrigin.group
                                      ? const BorderRadius.vertical(bottom: Radius.circular(16))
                                      : BorderRadius.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryTeal.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.call_split_outlined, color: AppColors.primaryTeal, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Text("Split", style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textBlack)),
                                        const Spacer(),
                                        Text(
                                          state.splitDescription,
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
                          if (state.origin != ExpenseOrigin.group) ...[
                            const Divider(height: 1, color: AppColors.borderGrey, indent: 16, endIndent: 16),
                          ],

                          // 2. Group Selection (Optional/Contextual)
                          if (state.origin != ExpenseOrigin.group)
                            InkWell(
                              onTap: () async {
                                final selectedGroup = await showGroupPickerFromList(
                                  context,
                                  state.commonGroups
                                );
                                if(context.mounted) {
                                  context.read<ExpenseBloc>().add(GroupChanged(selectedGroup));
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
                                      child: const Icon(Icons.group_outlined, color: AppColors.primaryTeal, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text("Group", style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textBlack)),
                                    const Spacer(),
                                    Text(
                                      state.group?.name ?? "Non-group",
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


                  const SizedBox(height: 16),

                  // Notes Section - Refined UI
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: BlocBuilder<ExpenseBloc, ExpenseState>(
                      builder: (context, state) {
                        return InkWell(
                          onTap: () async {
                            final result = await NavigationService.pushNamed(
                              AppRoutes.expenseNote,
                              args: {
                                'initialNote': state.notes,
                                'maxCharacters': AppConfigs.maxExpenseNoteCharacters,
                              },
                            );
                            if (result != null && result is String) {
                              if (context.mounted) {
                                context.read<ExpenseBloc>().add(NotesChanged(result));
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLightGrey.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    state.notes.isNotEmpty ? Icons.description_rounded : Icons.note_add_outlined,
                                    size: 20,
                                    color: state.notes.isNotEmpty ? AppColors.primaryTeal : AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.notes.isNotEmpty ? "Notes" : "Add detailed notes",
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        state.notes.isNotEmpty ? state.notes : "Keep track of receipt details or reminders",
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: state.notes.isNotEmpty ? AppColors.textBlack.withValues(alpha: 0.6) : AppColors.textGrey,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textGrey.withValues(alpha: 0.5)),
                              ],
                            ),
                          ),
                        );
                      },
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


  /// Triggers the final submission. Logic Moved form UI: Basic validation is now
  /// handled inside the BLoC's AddExpenseSubmitted handler or via on-the-fly state checks.
  void _onSave(BuildContext context, ExpenseState state) {
    context.read<ExpenseBloc>().add(AddExpenseSubmitted(groupId: state.group?.id));
  }
}
