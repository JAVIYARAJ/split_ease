import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/profile_picture_dialog.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/icon_utils.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_event.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_state.dart';
import 'package:split_ease/features/expenses/presentation/utils/expense_pdf_generator.dart';
import 'package:split_ease/features/expenses/presentation/widgets/expense_media_list.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/navigation_service.dart';

class ExpenseDetailPage extends StatefulWidget {
  const ExpenseDetailPage({super.key});

  @override
  State<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  final ValueNotifier<bool> _canPop = ValueNotifier<bool>(false);
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  ExpenseDetailLoaded? _lastLoadedState;

  @override
  void dispose() {
    _canPop.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _onBack() {
    _canPop.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context
            .read<ExpenseDetailBloc>()
            .state;
        Navigator.of(context).pop(state.hasChanges);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      var argument = ModalRoute
          .of(context)
          ?.settings
          .arguments as Map<String, dynamic>?;
      if (argument != null && argument["expanse_id"] != null) {
        context.read<ExpenseDetailBloc>().add(FetchExpenseDetailEvent(argument["expanse_id"]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataRefreshCubit, DataRefreshState>(
      listenWhen: (prev, curr) => curr.lastSignal?.type == RefreshType.expenseDetail,
      listener: (context, state) {
        final detailState = context
            .read<ExpenseDetailBloc>()
            .state;
        if (detailState is ExpenseDetailLoaded) {
          final expenseId = detailState.expenseDetail.id;
          if (context.read<DataRefreshCubit>().shouldRefresh(RefreshType.expenseDetail, id: expenseId)) {
            context.read<DataRefreshCubit>().clearRefresh(RefreshType.expenseDetail, id: expenseId);
            context.read<ExpenseDetailBloc>().add(MarkExpenseAsChanged());
            context.read<ExpenseDetailBloc>().add(FetchExpenseDetailEvent(expenseId));
          }
        }
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _canPop,
        builder: (context, canPop, child) {
          return PopScope(
            canPop: canPop,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _onBack();
            },
            child: BaseScreen(
              useSafeArea: true,
              backgroundColor: Theme.of(context).ext.scaffoldBg,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leadingWidth: 80,
                leading: AppBackButton(
                  onPressed: _onBack,
                ),
                title: Text(
                  "Expense Details",
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).ext.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  BlocBuilder<ExpenseDetailBloc, ExpenseDetailState>(
                    builder: (context, state) {
                      final loadedState = state is ExpenseDetailLoaded ? state : _lastLoadedState;
                      if (loadedState == null) return const SizedBox.shrink();

                      // If deleted, don't show edit/delete but show a restoration option in the banner/body instead
                      if (loadedState.isDeleted) {
                        return const SizedBox.shrink();
                      }

                      if (!loadedState.canManageExpense) {
                        return const SizedBox.shrink();
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state is ExpenseDetailLoading || state is ExpenseDeleteLoading || state is ExpenseRestoreLoading)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              width: 16,
                              height: 16,
                              child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                            ),
                          if (loadedState.expenseDetail.expenseType != 'settlement')
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).ext.inputFill,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit_outlined, color: Theme.of(context).ext.textPrimary, size: 20),
                                onPressed: () {
                                  NavigationUtils.handleResult(
                                    context: context,
                                    navigation: NavigationService.pushNamed(AppRoutes.addExpense, args: {'expense': loadedState.expenseDetail}),
                                    refreshType: RefreshType.expenseDetail,
                                    id: loadedState.expenseDetail.id,
                                    onRefresh: () {
                                      context.read<ExpenseDetailBloc>().add(MarkExpenseAsChanged());
                                      context.read<ExpenseDetailBloc>().add(FetchExpenseDetailEvent(loadedState.expenseDetail.id));
                                    },
                                  );
                                },
                              ),
                            ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).ext.inputFill,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).ext.error, size: 20),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, loadedState.expenseDetail.id);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      );
                    },
                  ),
                ],
              ),
              child: BlocListener<ExpenseDetailBloc, ExpenseDetailState>(
                listener: (context, state) {
                  if (state is ExpenseDeleted) {
                    AppAlerts.showSuccess(context, 'Expense deleted successfully');
                    Navigator.of(context).pop(true);
                  } else if (state is ExpenseDeleteError) {
                    AppAlerts.showError(context, state.message);
                  } else if (state is ExpenseRestored) {
                    AppAlerts.showSuccess(context, 'Expense restored successfully');
                  } else if (state is ExpenseRestoreError) {
                    AppAlerts.showError(context, state.message);
                  } else if (state is CommentActionError) {
                    AppAlerts.showError(context, state.message);
                  } else if (state is ExpenseDetailLoaded) {
                    _lastLoadedState = state;
                    if (state.editingCommentId == null) {
                      _commentController.clear();
                      _commentFocusNode.unfocus();
                    } else if (_commentController.text != state.editingCommentText) {
                      _commentController.text = state.editingCommentText ?? '';
                      _commentFocusNode.requestFocus();
                    }
                  }
                },
                child: BlocBuilder<ExpenseDetailBloc, ExpenseDetailState>(
                  builder: (context, state) {
                    if (state is ExpenseDetailError) {
                      return _buildErrorState(state.message);
                    }

                    final bool isLoading = state is ExpenseDetailLoading ||
                        state is ExpenseDetailInitial ||
                        state is ExpenseDeleteLoading ||
                        state is ExpenseRestoreLoading;

                    final loadedState = state is ExpenseDetailLoaded ? state : _lastLoadedState;
                    final entity = loadedState?.expenseDetail ?? _getMockEntity();
                    final bool isDeleted = loadedState?.isDeleted ?? false;
                    final bool showSkeleton = isLoading && _lastLoadedState == null;

                    return Skeletonizer(
                      enabled: showSkeleton,
                      child: Column(
                        children: [
                          if (isDeleted) _buildDeletedBanner(context, entity.id, loadedState?.canManageExpense ?? false),
                          if (!isDeleted && entity.expenseType == 'settlement') _buildSettlementBanner(),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildHeaderAmount(entity, isDeleted),
                                    const SizedBox(height: 32),
                                    _buildQuickInfo(loadedState ?? ExpenseDetailLoaded(_getMockEntity(), "")),
                                    if (loadedState != null) ...[
                                      const SizedBox(height: 16),
                                      _buildActivityLog(loadedState),
                                    ],
                                    const SizedBox(height: 24),
                                    _buildActionGrid(entity, isDeleted),
                                    const SizedBox(height: 24),
                                    if (entity.expenseType == 'settlement') ...[
                                      _buildSectionTitle("Settlement Details"),
                                      const SizedBox(height: 8),
                                      _buildSettlementDetailsSection(entity),
                                      const SizedBox(height: 24),
                                    ] else ...[
                                      _buildSectionTitle("Paid By"),
                                      const SizedBox(height: 8),
                                      _buildPaidBySection(entity),
                                      const SizedBox(height: 24),
                                    ],
                                    if (entity.notes != null && entity.notes!.isNotEmpty) ...[
                                      _buildSectionTitle("Notes"),
                                      const SizedBox(height: 8),
                                      _buildNotesSection(entity.notes!),
                                      const SizedBox(height: 24),
                                    ],
                                    if (entity.expenseType != 'settlement' && entity.splits.isNotEmpty) ...[
                                      _buildSectionTitle("Split Details"),
                                      const SizedBox(height: 8),
                                      _buildSplitsList(entity),
                                      const SizedBox(height: 24),
                                    ],
                                    if (entity.media.isNotEmpty) ...[
                                      _buildSectionTitle("Attachments"),
                                      const SizedBox(height: 8),
                                      ExpenseMediaList(entity: entity, canManageExpense: loadedState?.canManageExpense ?? false),
                                      const SizedBox(height: 24),
                                    ],
                                    _buildSectionTitle("Comments"),
                                    const SizedBox(height: 8),
                                    _buildCommentsList(
                                      loadedState?.comments ?? _getMockComments(),
                                      loadedState?.currentUserId ?? "",
                                      isDeleted,
                                      loadedState?.commentsLoading ?? false,
                                      entity.id,
                                    ),
                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Sticky Comments Section at the Bottom
                          if (!isDeleted)
                            Container(
                              color: Theme.of(context).ext.scaffoldBg,
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 12,
                                bottom: MediaQuery.of(context).padding.bottom > 0
                                    ? MediaQuery.of(context).padding.bottom
                                    : 20,
                              ),
                              child: _buildCommentsSection(entity, loadedState?.editingCommentId),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeletedBanner(BuildContext context, String expenseId, bool canRestore) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).ext.inputFill,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline_rounded, color: Theme.of(context).ext.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Deleted Expense",
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).ext.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Does not affect balances.",
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).ext.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (canRestore)
            TextButton.icon(
              onPressed: () {
                context.read<ExpenseDetailBloc>().add(RestoreExpenseEvent(expenseId));
              },
              icon: const Icon(Icons.restore_rounded, size: 16),
              label: Text(
                "Restore",
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryTeal,
                backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettlementBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Settle up expense is not editable, you can just delete or revert this tnx",
              style: GoogleFonts.outfit(
                color: Theme.of(context).ext.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String expanseId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).ext.surface,
          title: Text('Delete Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary)),
          content: Text('Are you sure you want to delete this expense? This will hide it and revert its metabolic effect on balances.', style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<ExpenseDetailBloc>().add(DeleteExpenseEvent(expanseId));
              },
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(color: Theme.of(context).ext.error, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Theme.of(context).ext.error),
          const SizedBox(height: 16),
          Text(
            "Failed to load expense details:\n$message",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
    );
  }

  Widget _buildHeaderAmount(ExpenseDetailEntity entity, bool isDeleted) {
    final formatter = NumberFormat('#,##0.00', 'en_IN');

    Color categoryColor = AppColors.primaryTeal;
    IconData categoryIcon = Icons.receipt_long_rounded;

    if (entity.category != null) {
      try {
        categoryColor = Color(int.parse(entity.category!.color.replaceFirst('#', '0xFF')));
      } catch (_) {}
      categoryIcon = IconUtils.getIconFromString(entity.category!.icon);
    }

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: categoryColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [BoxShadow(color: categoryColor.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 4))],
          ),
          child: Icon(categoryIcon, color: categoryColor, size: 32),
        ),
        if (entity.category != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: categoryColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              entity.category!.name,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
          ),
        ],
        SizedBox(height: entity.category != null ? 8 : 16),
        Text(
          entity.description,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDeleted ? Theme.of(context).ext.textTertiary : Theme.of(context).ext.textPrimary,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          "₹${formatter.format(entity.totalAmount)}",
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: isDeleted ? Theme.of(context).ext.textTertiary : Theme.of(context).ext.textPrimary,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo(ExpenseDetailLoaded state) {
    final entity = state.expenseDetail;
    String formattedDate = "Unknown Date";
    try {
      final parsed = DateTime.parse(entity.expenseDate);
      formattedDate = DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.calendar_today_rounded, "Date", formattedDate),
          Container(width: 1, height: 32, color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
          _buildInfoItem(Icons.person_outline_rounded, "Added By", state.creatorFirstName),
          Container(width: 1, height: 32, color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
          if (entity.splits.isEmpty)
            _buildInfoItem(Icons.lock_outline_rounded, "Scope", "Personal")
          else
            _buildInfoItem(Icons.group_outlined, "Group", state.groupDisplayName),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).ext.textSecondary, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Theme.of(context).ext.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog(ExpenseDetailLoaded state) {
    String formattedCreatedAt = "Unknown Date";
    if (state.expenseDetail.createdAt.isNotEmpty) {
      try {
        final parsed = DateTime.parse(state.expenseDetail.createdAt);
        formattedCreatedAt = DateFormat('MMM dd, yyyy • hh:mm a').format(parsed);
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primaryTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Created by ${state.creatorFirstName}",
                  style: GoogleFonts.outfit(color: Theme.of(context).ext.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                formattedCreatedAt,
                style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary, fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          if (state.expenseDetail.updatedBy != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Theme.of(context).ext.border.withValues(alpha: 0.2)),
            ),
            Row(
              children: [
                Icon(Icons.edit_note_rounded, size: 16, color: Theme.of(context).ext.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Updated by ${state.updatedByFirstName}",
                    style: GoogleFonts.outfit(color: Theme.of(context).ext.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  state.formattedUpdatedAt ?? "",
                  style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary, fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionGrid(ExpenseDetailEntity entity, bool isDeleted) {
    return Opacity(
      opacity: isDeleted ? 0.5 : 1.0,
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(Icons.receipt_rounded, "Receipt", isDeleted ? () {} : () async {
              final path = await ExpensePdfGenerator.generatePdf(entity);
              if (mounted) {
                NavigationService.pushNamed(AppRoutes.expensePdfPreview, args: {'pdfPath': path, 'expenseDescription': entity.description});
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).ext.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryTeal, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidBySection(ExpenseDetailEntity entity) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ProfilePictureDialog.show(
                      context,
                      avatarUrl: entity.paidBy.avatar,
                      name: entity.paidBy.fullName,
                    );
                  },
                  child: AppAvatar(
                    url: entity.paidBy.avatar,
                    radius: 18,
                    backgroundColor: Theme.of(context).ext.inputFill,
                    iconColor: Theme.of(context).ext.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.paidBy.fullName,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
                      ),
                      Text("Paid 100% of the cost", style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  "₹${NumberFormat('#,##0.00', 'en_IN').format(entity.totalAmount)}",
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary),
                ),
              ],
            ),
          ),
          if (entity.paymentMethod != null) ...[
            Divider(height: 1, color: Theme.of(context).ext.border.withValues(alpha: 0.2), indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(int.parse(entity.paymentMethod!.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconUtils.getIconFromString(entity.paymentMethod!.icon),
                      color: Color(int.parse(entity.paymentMethod!.color.replaceFirst('#', '0xFF'))),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Paid via ${entity.paymentMethod!.name}",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).ext.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettlementDetailsSection(ExpenseDetailEntity entity) {
    final paidBy = entity.paidBy;
    final paidTo = entity.splits.isNotEmpty ? entity.splits.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Paid By
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                AppAvatar(
                  url: paidBy.avatar,
                  radius: 18,
                  backgroundColor: Theme.of(context).ext.inputFill,
                  iconColor: Theme.of(context).ext.textSecondary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paidBy.fullName,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
                      ),
                      Text("Paid By", style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  "₹${NumberFormat('#,##0.00', 'en_IN').format(entity.totalAmount)}",
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary),
                ),
              ],
            ),
          ),

          if (paidTo != null) ...[
            Divider(height: 1, color: Theme.of(context).ext.border.withValues(alpha: 0.2), indent: 16, endIndent: 16),
            // Paid To
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AppAvatar(
                    url: paidTo.avatar,
                    radius: 18,
                    backgroundColor: Theme.of(context).ext.inputFill,
                    iconColor: Theme.of(context).ext.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paidTo.fullName,
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
                        ),
                        Text("Paid To", style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary)),
                      ],
                    ),
                  ),
                  Text(
                    "₹${NumberFormat('#,##0.00', 'en_IN').format(entity.totalAmount)}",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).ext.textPrimary),
                  ),
                ],
              ),
            ),
          ],

          if (entity.paymentMethod != null) ...[
            Divider(height: 1, color: Theme.of(context).ext.border.withValues(alpha: 0.2), indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(int.parse(entity.paymentMethod!.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconUtils.getIconFromString(entity.paymentMethod!.icon),
                      color: Color(int.parse(entity.paymentMethod!.color.replaceFirst('#', '0xFF'))),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Paid via ${entity.paymentMethod!.name}",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).ext.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    final isDark = Theme.of(context).isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryTeal.withValues(alpha: 0.08)
            : const Color(0xFFFFF9C4).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.primaryTeal.withValues(alpha: 0.25)
              : const Color(0xFFFFF176).withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        notes,
        textAlign: TextAlign.start,
        style: GoogleFonts.outfit(
          fontSize: 14,
          height: 1.6,
          letterSpacing: 0.2,
          color: Theme.of(context).ext.textPrimary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSplitsList(ExpenseDetailEntity entity) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entity.splits.length,
        separatorBuilder: (context, index) => Divider(height: 1, thickness: 1, color: Theme.of(context).ext.border.withValues(alpha: 0.2)),
        itemBuilder: (context, index) {
          final split = entity.splits[index];
          final isOwed = split.type != "participant";
          final amountText = isOwed ? "Owes" : "Participated";

          return _buildSplitListItem(
            name: split.fullName,
            avatarUrl: split.avatar,
            subText: amountText,
            amount: split.amount,
            isOwed: isOwed,
          );
        },
      ),
    );
  }

  Widget _buildSplitListItem({required String name, String? avatarUrl, required String subText, required double amount, required bool isOwed}) {
    final amountColor = isOwed ? AppColors.warningOrange : Theme.of(context).ext.textSecondary;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                ProfilePictureDialog.show(
                  context,
                  avatarUrl: avatarUrl,
                  name: name,
                );
              },
              child: AppAvatar(
                url: avatarUrl,
                radius: 18,
                backgroundColor: Theme.of(context).ext.inputFill,
                iconColor: Theme.of(context).ext.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(subText, style: GoogleFonts.outfit(fontSize: 13, color: Theme.of(context).ext.textSecondary)),
                ],
              ),
            ),
            Text(
              "₹${NumberFormat('#,##0.##', 'en_IN').format(amount)}",
              style: GoogleFonts.outfit(fontSize: 15, color: amountColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(ExpenseDetailEntity entity, String? editingCommentId) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (editingCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Editing comment", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.primaryTeal, fontWeight: FontWeight.w500)),
                  GestureDetector(
                    onTap: () => context.read<ExpenseDetailBloc>().add(CancelEditingCommentEvent()),
                    child: Icon(Icons.close_rounded, size: 16, color: Theme.of(context).ext.textSecondary),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              const AppAvatar(radius: 18, backgroundColor: AppColors.primaryTeal, iconColor: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  maxLength: 500,
                  maxLines: 4,
                  minLines: 1,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                    // Only show counter when actively typing (near limit)
                    if (!isFocused || currentLength < 400) return null;
                    return Text('$currentLength/$maxLength', style: GoogleFonts.outfit(fontSize: 10, color: currentLength >= 490 ? Theme.of(context).ext.error : Theme.of(context).ext.textSecondary));
                  },
                  style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).ext.textPrimary),
                  decoration: InputDecoration(
                    hintText: editingCommentId != null ? "Update your comment..." : "Add a comment...",
                    hintStyle: GoogleFonts.outfit(color: Theme.of(context).ext.textTertiary, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      if (editingCommentId != null) {
                        context.read<ExpenseDetailBloc>().add(UpdateExpenseCommentEvent(expenseId: entity.id, commentId: editingCommentId, comment: val.trim()));
                        context.read<ExpenseDetailBloc>().add(CancelEditingCommentEvent());
                      } else {
                        context.read<ExpenseDetailBloc>().add(AddExpenseCommentEvent(expenseId: entity.id, comment: val.trim()));
                        _commentController.clear();
                      }
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(editingCommentId != null ? Icons.check_circle_rounded : Icons.send_rounded, color: AppColors.primaryTeal, size: 20),
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    if (editingCommentId != null) {
                      context.read<ExpenseDetailBloc>().add(UpdateExpenseCommentEvent(expenseId: entity.id, commentId: editingCommentId, comment: _commentController.text.trim()));
                      context.read<ExpenseDetailBloc>().add(CancelEditingCommentEvent());
                    } else {
                      context.read<ExpenseDetailBloc>().add(AddExpenseCommentEvent(expenseId: entity.id, comment: _commentController.text.trim()));
                      _commentController.clear();
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<ExpenseCommentEntity> comments, String currentUserId, bool isDeleted, bool isLoading, String expenseId) {
    if (isLoading && comments.isEmpty) {
      comments = _getMockComments();
    }
    if (comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).ext.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            "No comments yet",
            style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return Opacity(
      opacity: isDeleted ? 0.6 : 1.0,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final comment = comments[index];
          final bool isMe = comment.user.id == currentUserId;

          Widget commentWidget = Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryTeal.withValues(alpha: 0.08) : Theme.of(context).ext.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
                border: Border.all(color: isMe ? AppColors.primaryTeal.withValues(alpha: 0.2) : Theme.of(context).ext.border.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe) ...[
                    AppAvatar(
                      url: comment.user.avatar,
                      radius: 14,
                      backgroundColor: Theme.of(context).ext.inputFill,
                      iconColor: Theme.of(context).ext.textSecondary,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMe) ...[
                              Text(
                                comment.user.fullName,
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _formatCommentDate(comment.createdAt),
                              style: GoogleFonts.outfit(fontSize: 10, color: Theme.of(context).ext.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.content,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).ext.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 12),
                    AppAvatar(
                      url: comment.user.avatar,
                      radius: 16,
                      backgroundColor: Theme.of(context).ext.inputFill,
                      iconColor: Theme.of(context).ext.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          );

          if (isMe && !isDeleted) {
            return Dismissible(
              key: ValueKey("comment_${comment.id}"),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Swipe Left to Right -> Edit
                  context.read<ExpenseDetailBloc>().add(SetEditingCommentEvent(commentId: comment.id, commentText: comment.content));
                  return false; // don't actually dismiss
                } else if (direction == DismissDirection.endToStart) {
                  // Swipe Right to Left -> Delete
                  _confirmDeleteComment(context, expenseId, comment.id);
                  return false; // wait for confirmation dialog to handle it
                }
                return false;
              },
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 24),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: const Icon(Icons.edit_rounded, color: AppColors.primaryTeal, size: 24),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Icon(Icons.delete_rounded, color: Theme.of(context).ext.error, size: 24),
              ),
              child: commentWidget,
            );
          }

          return commentWidget;
        },
      ),
    );
  }

  void _confirmDeleteComment(BuildContext context, String expenseId, String commentId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).ext.surface,
          title: Text("Delete Comment", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary)),
          content: Text("Are you sure you want to delete this comment?", style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel", style: GoogleFonts.outfit(color: Theme.of(context).ext.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).ext.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                context.read<ExpenseDetailBloc>().add(
                  DeleteExpenseCommentEvent(
                    expenseId: expenseId,
                    commentId: commentId,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: Text("Delete", style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatCommentDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return DateFormat('MMM dd').format(date);
    } catch (_) {
      return "";
    }
  }

  // Fallback entity to render the Skeleton properly.
  ExpenseDetailEntity _getMockEntity() {
    return const ExpenseDetailEntity(
      id: "",
      description: "Loading...",
      notes: null,
      expenseType: "expense",
      totalAmount: 1000.0,
      expenseDate: "2026-02-21T00:00:00+00:00",
      createdAt: "2026-02-21T00:00:00+00:00",
      paidBy: ExpenseUserEntity(id: "", fullName: "User Name"),
      createdBy: ExpenseUserEntity(id: "", fullName: "User Name"),
      updatedAt: null,
      updatedBy: null,
      splits: [
        ExpenseSplitEntity(type: "you_owe", amount: 500, userId: "1", fullName: "Test User"),
        ExpenseSplitEntity(type: "participant", amount: 500, userId: "2", fullName: "Test User"),
      ],
    );
  }

  List<ExpenseCommentEntity> _getMockComments() {
    return [
      ExpenseCommentEntity(
          id: "mock1",
          content: "Loading...",
          createdAt: DateTime.now().toIso8601String(),
          user: const ExpenseUserEntity(id: "", fullName: "User Name")
      ),
    ];
  }
}