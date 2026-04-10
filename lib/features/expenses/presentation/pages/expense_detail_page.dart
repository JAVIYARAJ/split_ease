import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_event.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_state.dart';
import 'package:split_ease/features/expenses/presentation/utils/expense_pdf_generator.dart';

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

  @override
  void dispose() {
    _canPop.dispose();
    _commentController.dispose();
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
              backgroundColor: AppColors.backgroundLightGrey, 
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack),
                  onPressed: _onBack,
                ),
                title: Text(
                  "Expense Details",
                  style: GoogleFonts.outfit(color: AppColors.textBlack, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                actions: [
                  BlocBuilder<ExpenseDetailBloc, ExpenseDetailState>(
                    builder: (context, state) {
                      if (state is! ExpenseDetailLoaded) return const SizedBox.shrink();

                      // If deleted, don't show edit/delete but show a restoration option in the banner/body instead
                      if (state.isDeleted) {
                        return const SizedBox.shrink();
                      }

                      if (!state.canManageExpense) {
                        return const SizedBox.shrink();
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.textBlack),
                            onPressed: () {
                              NavigationUtils.handleResult(
                                context: context,
                                navigation: NavigationService.pushNamed(AppRoutes.addExpense, args: {'expense': state.expenseDetail}),
                                refreshType: RefreshType.expenseDetail,
                                id: state.expenseDetail.id,
                                onRefresh: () {
                                  context.read<ExpenseDetailBloc>().add(MarkExpenseAsChanged());
                                  context.read<ExpenseDetailBloc>().add(FetchExpenseDetailEvent(state.expenseDetail.id));
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, state.expenseDetail.id);
                            },
                          ),
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
                    // In a detail page, we might want to stay but show the deleted state, 
                    // or pop back. Assuming we pop for now as before.
                    Navigator.of(context).pop(true); 
                  } else if (state is ExpenseDeleteError) {
                    AppAlerts.showError(context, state.message);
                  } else if (state is ExpenseRestored) {
                    AppAlerts.showSuccess(context, 'Expense restored successfully');
                  } else if (state is ExpenseRestoreError) {
                    AppAlerts.showError(context, state.message);
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
                                         
                    final entity = state is ExpenseDetailLoaded ? state.expenseDetail : _getMockEntity();
                    final bool isDeleted = state is ExpenseDetailLoaded && state.isDeleted;

                    return Skeletonizer(
                      enabled: isLoading,
                      child: Column(
                        children: [
                          if (isDeleted) _buildDeletedBanner(context, entity.id, (state as ExpenseDetailLoaded).canManageExpense),
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
                                    _buildQuickInfo(state is ExpenseDetailLoaded ? state : ExpenseDetailLoaded(_getMockEntity(), "")),
                                    if (state is ExpenseDetailLoaded && state.expenseDetail.updatedBy != null) ...[
                                      const SizedBox(height: 12),
                                      _buildLastUpdatedInfo(state),
                                    ],
                                    const SizedBox(height: 24),
                                    _buildActionGrid(entity, isDeleted),
                                    const SizedBox(height: 24),
                                    _buildSectionTitle("Paid By"),
                                    const SizedBox(height: 8),
                                    _buildPaidBySection(entity),
                                    const SizedBox(height: 24),
                                    if (entity.notes != null && entity.notes!.isNotEmpty) ...[
                                      _buildSectionTitle("Notes"),
                                      const SizedBox(height: 8),
                                      _buildNotesSection(entity.notes!),
                                      const SizedBox(height: 24),
                                    ],
                                    _buildSectionTitle("Comments"),
                                    const SizedBox(height: 8),
                                    _buildCommentsList(entity, state is ExpenseDetailLoaded ? state.currentUserId : "", isDeleted),
                                    const SizedBox(height: 24),
                                    _buildSectionTitle("Split Details"),
                                    const SizedBox(height: 8),
                                    _buildSplitsList(entity),
                                    const SizedBox(height: 80), 
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Sticky Comments Section at the Bottom
                          if (!isDeleted)
                          Container(
                            color: AppColors.backgroundLightGrey,
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 12,
                              bottom: MediaQuery
                                  .of(context)
                                  .padding
                                  .bottom > 0 ? MediaQuery
                                  .of(context)
                                  .padding
                                  .bottom : 20,
                            ),
                            child: _buildCommentsSection(entity),
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
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.errorRed.withValues(alpha: 0.1),
            AppColors.errorRed.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.errorRed.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Expense Deleted",
                  style: GoogleFonts.outfit(
                    color: AppColors.errorRed,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "This item is no longer active.",
                  style: GoogleFonts.outfit(
                    color: AppColors.errorRed.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (canRestore)
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 0,
              child: InkWell(
                onTap: () {
                  context.read<ExpenseDetailBloc>().add(RestoreExpenseEvent(expenseId));
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        "UNDO",
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
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
          title: Text('Delete Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          content: Text('Are you sure you want to delete this expense? This will hide it and revert its metabolic effect on balances.', style: GoogleFonts.outfit()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textGrey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<ExpenseDetailBloc>().add(DeleteExpenseEvent(expanseId));
              },
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(color: AppColors.errorRed, fontWeight: FontWeight.w600),
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
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.errorRed),
          const SizedBox(height: 16),
          Text(
            "Failed to load expense details:\n$message",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
    );
  }

  Widget _buildHeaderAmount(ExpenseDetailEntity entity, bool isDeleted) {
    final formatter = NumberFormat('#,##0.00', 'en_IN');

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGreyLight, width: 1),
            image: entity.group?.groupIcon != null
                ? DecorationImage(image: CachedNetworkImageProvider(entity.group!.groupIcon!), fit: BoxFit.cover)
                : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: entity.group?.groupIcon == null ? const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 32) : null,
        ),
        const SizedBox(height: 16),
        Text(
          entity.description,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22, 
            fontWeight: FontWeight.w700, 
            color: isDeleted ? AppColors.textGrey : AppColors.textBlack,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          "₹${formatter.format(entity.totalAmount)}",
          style: GoogleFonts.outfit(
            fontSize: 36, 
            fontWeight: FontWeight.w700, 
            letterSpacing: -1, 
            color: isDeleted ? AppColors.textGrey : AppColors.textBlack,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreyLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.calendar_today_rounded, "Date", formattedDate),
          Container(width: 1, height: 32, color: AppColors.borderGreyLight),
          _buildInfoItem(Icons.person_outline_rounded, "Added By", state.creatorFirstName),
          Container(width: 1, height: 32, color: AppColors.borderGreyLight),
          _buildInfoItem(Icons.group_outlined, "Group", state.groupDisplayName),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.iconGrey, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(color: AppColors.iconGrey, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textBlack, fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedInfo(ExpenseDetailLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.history_rounded, size: 14, color: AppColors.textGrey),
        const SizedBox(width: 4),
        Text(
          "Last updated by ${state.updatedByFirstName} on ${state.formattedUpdatedAt}",
          style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGreyLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidBySection(ExpenseDetailEntity entity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreyLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          AppAvatar(url: entity.paidBy.avatar, radius: 22, backgroundColor: AppColors.backgroundLightGrey, iconColor: AppColors.textGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entity.paidBy.fullName,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                ),
                Text("Paid 100% of the cost", style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
              ],
            ),
          ),
          Text(
            "₹${NumberFormat('#,##0.00', 'en_IN').format(entity.totalAmount)}",
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textBlack),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withValues(alpha: 0.3), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFF176).withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Text(
        notes,
        textAlign: TextAlign.start,
        style: GoogleFonts.outfit(
          fontSize: 14,
          height: 1.6,
          letterSpacing: 0.2,
          color: AppColors.textBlack.withValues(alpha: 0.8),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSplitsList(ExpenseDetailEntity entity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreyLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entity.splits.length,
        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: AppColors.backgroundLightGrey),
        itemBuilder: (context, index) {
          final split = entity.splits[index];
          final isOwed = split.type != "participant";
          final amountText = isOwed ? "Owes" : "Participated";

          return _buildSplitListItem(name: split.fullName,
              avatarUrl: split.avatar,
              subText: amountText,
              amount: split.amount,
              isOwed: isOwed);
        },
      ),
    );
  }

  Widget _buildSplitListItem({required String name, String? avatarUrl, required String subText, required double amount, required bool isOwed}) {
    final amountColor = isOwed ? AppColors.warningOrange : AppColors.textGrey;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            AppAvatar(url: avatarUrl, radius: 19, backgroundColor: AppColors.backgroundLightGrey, iconColor: AppColors.textGrey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                  ),
                  const SizedBox(height: 2),
                  Text(subText, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
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

  Widget _buildCommentsSection(ExpenseDetailEntity entity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreyLight),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const AppAvatar(radius: 18, backgroundColor: AppColors.primary, iconColor: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              style: GoogleFonts.outfit(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: GoogleFonts.outfit(color: AppColors.iconGrey, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  context.read<ExpenseDetailBloc>().add(AddExpenseCommentEvent(expenseId: entity.id, comment: val.trim()));
                  _commentController.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
            onPressed: () {
              if (_commentController.text.trim().isNotEmpty) {
                context.read<ExpenseDetailBloc>().add(AddExpenseCommentEvent(expenseId: entity.id, comment: _commentController.text.trim()));
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(ExpenseDetailEntity entity, String currentUserId, bool isDeleted) {
    if (entity.comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGreyLight),
        ),
        child: Center(
          child: Text(
            "No comments yet",
            style: GoogleFonts.outfit(color: AppColors.textGrey, fontSize: 14),
          ),
        ),
      );
    }

    return Opacity(
      opacity: isDeleted ? 0.6 : 1.0,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entity.comments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final comment = entity.comments[index];
          final bool isMe = comment.user.id == currentUserId;
    
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surfaceWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
                border: Border.all(color: isMe ? AppColors.primary.withValues(alpha: 0.1) : AppColors.borderGreyLight),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe) ...[
                    AppAvatar(url: comment.user.avatar, radius: 16, backgroundColor: AppColors.backgroundLightGrey, iconColor: AppColors.textGrey),
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
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _formatCommentDate(comment.createdAt),
                              style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textGrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.content,
                          textAlign: isMe ? TextAlign.right : TextAlign.left,
                          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textBlack.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 12),
                    AppAvatar(url: comment.user.avatar, radius: 16, backgroundColor: AppColors.backgroundLightGrey, iconColor: AppColors.textGrey),
                  ],
                ],
              ),
            ),
          );
        },
      ),
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
      comments: const [],
      splits: const [
        ExpenseSplitEntity(type: "you_owe", amount: 500, userId: "1", fullName: "Test User"),
        ExpenseSplitEntity(type: "participant", amount: 500, userId: "2", fullName: "Test User"),
      ],
    );
  }
}