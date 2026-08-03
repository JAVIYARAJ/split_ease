import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/app_error_full_screen_dialog.dart';
import 'package:split_ease/core/presentation/widgets/group_picker_sheet.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/theme/app_layout.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_ease/core/services/image_picker_service.dart';
import 'package:split_ease/injection_container.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import 'package:split_ease/core/config/app_configs.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:split_ease/features/expenses/presentation/widgets/calculator_bottom_sheet.dart';

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
        
        String? lastUsedCategoryId;
        if (appUserState is AppUserLoggedIn) {
          lastUsedCategoryId = appUserState.user.lastExpenseCategoryId;
        }
        
        context.read<ExpenseBloc>().add(ExpenseInitialized(
          group: group,
          friend: friend,
          currentUserId: currentUserId,
          origin: origin,
          lastUsedCategoryId: lastUsedCategoryId,
        ));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).ext.backgroundGrey, // Using a light grey background to make cards pop
      appBar: AppBar(
        backgroundColor: Theme.of(context).ext.backgroundGrey,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        leadingWidth: AppLayout.appBarLeadingWidth,
        title: BlocBuilder<ExpenseBloc, ExpenseState>(
          buildWhen: (previous, current) => previous.isEdit != current.isEdit,
          builder: (context, state) {
            return Text(
              state.isEdit ? "Edit expense" : "Add expense",
              style: GoogleFonts.outfit(color: Theme.of(context).ext.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
            );
          },
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              if (state.status == ExpenseStatus.loading) {
                 return const Padding(
                   padding: EdgeInsets.only(right: 24.0),
                   child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal))),
                 );
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: () => _onSave(context, state),
                  child: Text(
                    "Save",
                    style: GoogleFonts.outfit(color: AppColors.primaryTeal, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state.status == ExpenseStatus.success) {
            if (state.selectedCategory != null) {
              final appUserCubit = context.read<AppUserCubit>();
              final appUserState = appUserCubit.state;
              if (appUserState is AppUserLoggedIn) {
                appUserCubit.updateUser(
                  appUserState.user.copyWith(lastExpenseCategoryId: state.selectedCategory!.id)
                );
              }
            }
            
            AppAlerts.showSuccess(context, state.isEdit ? 'Expense updated successfully!' : 'Expense added successfully!');
            Navigator.pop(context, true);
          } else if (state.status == ExpenseStatus.failure || state.status == ExpenseStatus.validationError) {
            AppAlerts.showError(context, state.errorMessage ?? 'An error occurred');
          }
        },
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state.status == ExpenseStatus.failure && state.categories.isEmpty) {
              return AppErrorFullScreenWidget(
                errorMessage: state.errorMessage,
                onRefresh: () async {
                  final bloc = context.read<ExpenseBloc>();
                  final appUserState = context.read<AppUserCubit>().state;
                  String? currentUserId;
                  if (appUserState is AppUserLoggedIn) {
                    currentUserId = appUserState.user.id;
                  }
                  bloc.add(ExpenseInitialized(
                    group: state.group,
                    friend: state.friend,
                    currentUserId: currentUserId,
                    origin: state.origin,
                  ));
                  final nextState = await bloc.stream.firstWhere(
                    (s) => s.status != ExpenseStatus.loading,
                  );
                  return nextState.status != ExpenseStatus.failure;
                },
              );
            }

            final group = state.group;
            final friend = state.friend;
            final members = state.groupMembers;
            final payerName = state.payerName;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Type Toggle for Global Origin
                      if (!state.isEdit && group == null && friend == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).ext.border.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOutCubic,
                                    alignment: state.origin != ExpenseOrigin.personal ? Alignment.centerLeft : Alignment.centerRight,
                                    child: FractionallySizedBox(
                                      widthFactor: 0.5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).ext.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (state.origin == ExpenseOrigin.personal) {
                                            context.read<ExpenseBloc>().add(const ExpenseOriginChanged(ExpenseOrigin.global));
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          alignment: Alignment.center,
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 250),
                                            curve: Curves.easeInOut,
                                             style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: state.origin != ExpenseOrigin.personal ? FontWeight.w700 : FontWeight.w600,
                                              color: state.origin != ExpenseOrigin.personal ? Theme.of(context).ext.textPrimary : Theme.of(context).ext.textSecondary,
                                            ),
                                            child: const Text("Shared"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (state.origin != ExpenseOrigin.personal) {
                                            context.read<ExpenseBloc>().add(const ExpenseOriginChanged(ExpenseOrigin.personal));
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          alignment: Alignment.center,
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 250),
                                            curve: Curves.easeInOut,
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: state.origin == ExpenseOrigin.personal ? FontWeight.w700 : FontWeight.w600,
                                              color: state.origin == ExpenseOrigin.personal ? Theme.of(context).ext.textPrimary : Theme.of(context).ext.textSecondary,
                                            ),
                                            child: const Text("Personal"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Context Badge
                      if (group != null)
                        _buildContextBadge(
                          icon: group.groupIcon != null
                              ? CachedNetworkImageProvider(group.groupIcon!) as ImageProvider
                              : null,
                          fallbackIcon: Icons.group_rounded,
                          text: "In: ${group.name ?? "Non-group expense"}",
                        )
                      else if (friend != null)
                        _buildContextBadge(
                          icon: friend.imageUrl != null
                              ? CachedNetworkImageProvider(friend.imageUrl!) as ImageProvider
                              : null,
                          fallbackIcon: Icons.person_rounded,
                          text: "With: ${friend.name}",
                        ),

                      const SizedBox(height: 32),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextField(
                          controller: _descriptionController,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary),
                          decoration: InputDecoration(
                            hintText: "What was this for?",
                            hintStyle: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textGrey.withValues(alpha: 0.4)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (value) => context.read<ExpenseBloc>().add(DescriptionChanged(value)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Amount
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(fontSize: 64, fontWeight: FontWeight.w900, color: Theme.of(context).ext.textPrimary, height: 1.0),
                              decoration: InputDecoration(
                                hintText: "₹0",
                                hintStyle: GoogleFonts.outfit(fontSize: 64, fontWeight: FontWeight.w900, color: AppColors.textGrey.withValues(alpha: 0.3), height: 1.0),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) => context.read<ExpenseBloc>().add(AmountChanged(value)),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.calculate_rounded, color: AppColors.primaryTeal, size: 24),
                                ),
                                onPressed: () async {
                                  // Hide keyboard before opening bottom sheet
                                  FocusScope.of(context).unfocus();
                                  final result = await showModalBottomSheet<String>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => CalculatorBottomSheet(initialValue: _amountController.text),
                                  );
                                  if (result != null && result.isNotEmpty && context.mounted) {
                                    _amountController.text = result;
                                    context.read<ExpenseBloc>().add(AmountChanged(result));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),

                      // Settings Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).ext.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Skeletonizer(
                          enabled: state.groupMembersStatus == ExpenseStatus.loading,
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                              _buildConfigRow(
                                icon: state.selectedCategory != null ? IconUtils.getIconFromString(state.selectedCategory!.icon) : Icons.category_rounded,
                                iconColor: state.selectedCategory != null 
                                    ? Color(int.parse(state.selectedCategory!.color.replaceFirst('#', '0xFF'))) 
                                    : null,
                                label: "Category",
                                value: state.selectedCategory?.name ?? "Select Category",
                                isTop: true,
                                isBottom: false,
                                onTap: () => _showCategoryPicker(context, state),
                              ),
                              _buildDivider(),
                              _buildConfigRow(
                                icon: state.selectedPaymentMethod != null ? IconUtils.getIconFromString(state.selectedPaymentMethod!.icon) : Icons.payments_rounded,
                                iconColor: state.selectedPaymentMethod != null 
                                    ? Color(int.parse(state.selectedPaymentMethod!.color.replaceFirst('#', '0xFF'))) 
                                    : null,
                                label: "Payment Method",
                                value: state.selectedPaymentMethod?.name ?? "Select Method",
                                isBottom: state.origin == ExpenseOrigin.personal,
                                onTap: () => _showPaymentMethodPicker(context, state),
                              ),
                              if (state.origin != ExpenseOrigin.personal) ...[
                                _buildDivider(),
                                _buildConfigRow(
                                  icon: Icons.person_outline_rounded,
                                  label: "Paid by",
                                  value: payerName ?? "you",
                                  onTap: () => _handlePaidBySelection(context, state, members),
                                ),
                                _buildDivider(),
                                _buildConfigRow(
                                  icon: Icons.call_split_rounded,
                                  label: "Split",
                                  value: state.splitDescription,
                                  isBottom: state.origin == ExpenseOrigin.group,
                                  onTap: () => _handleSplitSelection(context, state, members),
                                ),
                                if (state.origin != ExpenseOrigin.group) ...[
                                  _buildDivider(),
                                  _buildConfigRow(
                                    icon: Icons.groups_outlined,
                                    label: "Group",
                                    value: state.group?.name ?? "Non-group expense",
                                    isBottom: true,
                                    onTap: () async {
                                      final selectedGroup = await showGroupPickerFromList(context, state.commonGroups);
                                      if(context.mounted) {
                                        context.read<ExpenseBloc>().add(GroupChanged(selectedGroup));
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Secondary Settings Card (Date & Notes)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).ext.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildConfigRow(
                              icon: Icons.calendar_today_rounded,
                              label: "Date",
                              value: state.date != null ? DateFormat('MMMM d, yyyy').format(state.date!) : "Today",
                              valueColor: Theme.of(context).ext.textPrimary,
                              isTop: true,
                              onTap: () async {
                                final result = await NavigationService.pushNamed(
                                  AppRoutes.dateSelection,
                                  args: {'initialDate': state.date},
                                );
                                if (result != null && result is DateTime && context.mounted) {
                                  context.read<ExpenseBloc>().add(DateChanged(result));
                                }
                              },
                            ),
                            _buildDivider(),
                            _buildConfigRow(
                              icon: Icons.notes_rounded,
                              label: "Note",
                              value: state.notes.isNotEmpty ? state.notes : "Add a note",
                              valueColor: state.notes.isNotEmpty ? Theme.of(context).ext.textPrimary : Theme.of(context).ext.textSecondary,
                              onTap: () async {
                                final result = await NavigationService.pushNamed(
                                  AppRoutes.expenseNote,
                                  args: {
                                    'initialNote': state.notes,
                                    'maxCharacters': AppConfigs.maxExpenseNoteCharacters,
                                  },
                                );
                                if (result != null && result is String && context.mounted) {
                                  context.read<ExpenseBloc>().add(NotesChanged(result));
                                }
                              },
                            ),
                            _buildDivider(),
                            Builder(
                              builder: (context) {
                                final totalAttachments = state.attachments.length + state.existingMedia.length;
                                return _buildConfigRow(
                                  icon: Icons.receipt_long_rounded,
                                  label: "Receipt",
                                  value: totalAttachments > 0 ? "$totalAttachments attached" : "Add receipt",
                                  valueColor: totalAttachments > 0 ? Theme.of(context).ext.textPrimary : Theme.of(context).ext.textSecondary,
                                  isBottom: true,
                                  onTap: () => _showAttachmentPicker(context, state),
                                );
                              }
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContextBadge({ImageProvider? icon, required IconData fallbackIcon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: icon == null ? AppColors.primaryTeal : null,
              image: icon != null ? DecorationImage(image: icon, fit: BoxFit.cover) : null,
            ),
            child: icon == null ? Icon(fallbackIcon, color: Colors.white, size: 12) : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? iconColor,
    required VoidCallback onTap,
    bool isTop = false,
    bool isBottom = false,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.primaryTeal;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(24) : Radius.zero,
        bottom: isBottom ? const Radius.circular(24) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: effectiveIconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, color: valueColor ?? AppColors.primaryTeal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: Theme.of(context).ext.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Theme.of(context).ext.border.withValues(alpha: 0.5), indent: 64, endIndent: 20);
  }

  void _handlePaidBySelection(BuildContext context, ExpenseState state, dynamic members) {
    if (state.groupMembersStatus == ExpenseStatus.loading) return;
    context.read<ExpenseBloc>().add(ValidateNavigation(
      onValid: () async {
        final result = await NavigationService.pushNamed(
          AppRoutes.payerSelection,
          args: {'members': members, 'currentPayerId': state.payerId},
        );
        if (result != null && result is String && context.mounted) {
          context.read<ExpenseBloc>().add(PayerChanged(result));
        }
      },
    ));
  }

  void _handleSplitSelection(BuildContext context, ExpenseState state, dynamic members) {
    if (state.groupMembersStatus == ExpenseStatus.loading) return;
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
        if (result != null && result is Map<String, dynamic> && context.mounted) {
          context.read<ExpenseBloc>().add(SplitTypeChanged(result['splitType']));
          context.read<ExpenseBloc>().add(SplitOptionChanged(result['splits']));
        }
      },
    ));
  }

  /// Triggers the final submission.
  void _onSave(BuildContext context, ExpenseState state) {
    context.read<ExpenseBloc>().add(AddExpenseSubmitted(groupId: state.group?.id));
  }

  Future<void> _showCategoryPicker(BuildContext context, ExpenseState state) async {
    final appUserState = context.read<AppUserCubit>().state;
    String? lastUsedCategoryId;
    if (!state.isEdit && appUserState is AppUserLoggedIn) {
      lastUsedCategoryId = appUserState.user.lastExpenseCategoryId;
    }

    final result = await NavigationService.pushNamed(
      AppRoutes.categorySelection,
      args: {
        'categories': state.categories,
        'selectedCategory': state.selectedCategory,
        'lastUsedCategoryId': lastUsedCategoryId,
      },
    );
    if (result != null && result is ExpenseCategoryEntity && context.mounted) {
      context.read<ExpenseBloc>().add(CategoryChanged(result));
    }
  }

  void _showPaymentMethodPicker(BuildContext context, ExpenseState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).ext.scaffoldBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (bottomSheetContext) {
        return Container(
          padding: EdgeInsets.only(
            top: 24, 
            bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Payment Method",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: state.paymentMethods.length,
                  itemBuilder: (listContext, index) {
                    final method = state.paymentMethods[index];
                    final isSelected = state.selectedPaymentMethod?.id == method.id;
                    final color = Color(int.parse(method.color.replaceFirst('#', '0xFF')));
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(IconUtils.getIconFromString(method.icon), color: color, size: 24),
                      ),
                      title: Text(
                        method.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: Theme.of(context).ext.textPrimary,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal) : null,
                      onTap: () {
                        context.read<ExpenseBloc>().add(PaymentMethodChanged(method));
                        Navigator.pop(bottomSheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentPicker(BuildContext context, ExpenseState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).ext.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).ext.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryTeal, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                "Add a Receipt",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).ext.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Attach a clear image or PDF document to keep track of your expenses.",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).ext.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    context: bottomSheetContext,
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    color: const Color(0xFF4F46E5),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _pickMedia(context, state, true);
                    },
                  ),
                  _buildAttachmentOption(
                    context: bottomSheetContext,
                    icon: Icons.photo_library_rounded,
                    label: "Gallery",
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _pickMedia(context, state, false);
                    },
                  ),
                  _buildAttachmentOption(
                    context: bottomSheetContext,
                    icon: Icons.picture_as_pdf_rounded,
                    label: "Document",
                    color: const Color(0xFFF59E0B),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      await Future.delayed(const Duration(milliseconds: 300));
                      try {
                        FilePickerResult? result = await FilePicker.pickFiles(
                          type: FileType.any,
                        );
                        if (result != null && result.files.single.path != null && context.mounted) {
                          final currentAttachments = List<String>.from(state.attachments);
                          currentAttachments.add(result.files.single.path!);
                          context.read<ExpenseBloc>().add(AttachmentsChanged(currentAttachments));
                        }
                      } catch (e) {
                        debugPrint("FilePicker Error: $e");
                        if (context.mounted) {
                          AppAlerts.showError(context, "Error: $e");
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).ext.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(BuildContext context, ExpenseState state, bool isCamera) async {
    try {
      final picker = sl<ImagePickerService>();
      final file = isCamera ? await picker.pickImage(source: ImageSource.camera) : await picker.pickImage(source: ImageSource.gallery);
      
      if (file != null && context.mounted) {
        final currentAttachments = List<String>.from(state.attachments);
        currentAttachments.add(file.path);
        context.read<ExpenseBloc>().add(AttachmentsChanged(currentAttachments));
      }
    } catch (e) {
      if (context.mounted) {
         AppAlerts.showError(context, "Could not pick image");
      }
    }
  }
}
