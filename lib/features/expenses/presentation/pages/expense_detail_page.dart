import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_bloc.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_event.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_state.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/presentation/utils/expense_pdf_generator.dart';
import 'package:split_ease/features/expenses/presentation/pages/expense_pdf_preview_page.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/navigation_service.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/injection_container.dart';

class ExpenseDetailPage extends StatefulWidget {
  const ExpenseDetailPage({super.key});

  @override
  State<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  final ValueNotifier<bool> _canPop = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _canPop.dispose();
    super.dispose();
  }

  void _onBack() {
    _canPop.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<ExpenseDetailBloc>().state;
        Navigator.of(context).pop(state.hasChanges);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      var argument = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
        final detailState = context.read<ExpenseDetailBloc>().state;
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
            backgroundColor: AppColors.backgroundLightGrey, // Using a gentle background for card styling
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

                    // Only show edit/delete if the user has permissions (creator or owner/admin of group)
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
                  Navigator.of(context).pop(true); // Return true on deletion
                } else if (state is ExpenseDeleteError) {
                  AppAlerts.showError(context, 'Failed to delete expense: ${state.message}');
                }
              },
              child: BlocBuilder<ExpenseDetailBloc, ExpenseDetailState>(
                builder: (context, state) {
                  if (state is ExpenseDetailError) {
                    return _buildErrorState(state.message);
                  }

                  final bool isLoading = state is ExpenseDetailLoading || state is ExpenseDetailInitial || state is ExpenseDeleteLoading;
                  final entity = state is ExpenseDetailLoaded ? state.expenseDetail : _getMockEntity();

                  return Skeletonizer(
                    enabled: isLoading,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHeaderAmount(entity),
                                  const SizedBox(height: 32),
                                  _buildQuickInfo(state is ExpenseDetailLoaded ? state : ExpenseDetailLoaded(_getMockEntity(), "")),
                                  const SizedBox(height: 24),
                                  _buildActionGrid(entity),
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
                                  _buildSectionTitle("Split Details"),
                                  const SizedBox(height: 8),
                                  _buildSplitsList(entity),
                                  const SizedBox(height: 80), // Bottom padding
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Sticky Comments Section at the Bottom
                        Container(
                          color: AppColors.backgroundLightGrey,
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 12,
                            bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 20,
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

  void _showDeleteConfirmationDialog(BuildContext context, String expanseId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          content: Text('Are you sure you want to delete this expense? This action cannot be undone.', style: GoogleFonts.outfit()),
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

  Widget _buildHeaderAmount(ExpenseDetailEntity entity) {
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
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textBlack),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          "₹${formatter.format(entity.totalAmount)}",
          style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1, color: AppColors.textBlack),
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

  Widget _buildActionGrid(ExpenseDetailEntity entity) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(Icons.receipt_rounded, "Receipt", () async {
            final path = await ExpensePdfGenerator.generatePdf(entity);
            if (mounted) {
              NavigationService.pushNamed(AppRoutes.expensePdfPreview, args: {'pdfPath': path, 'expenseDescription': entity.description});
            }
          }),
        ),
      ],
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
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withValues(alpha: 0.3), // Very light yellow sticky note feel
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

          return _buildSplitListItem(name: split.fullName, avatarUrl: split.avatar, subText: amountText, amount: split.amount, isOwed: isOwed);
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
              style: GoogleFonts.outfit(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: GoogleFonts.outfit(color: AppColors.iconGrey, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
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
      splits: const [
        ExpenseSplitEntity(type: "you_owe", amount: 500, userId: "1", fullName: "Test User"),
        ExpenseSplitEntity(type: "participant", amount: 500, userId: "2", fullName: "Test User"),
      ],
    );
  }
