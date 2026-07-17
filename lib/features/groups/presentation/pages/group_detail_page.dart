import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/app_empty_state.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_expense_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_detail_bloc.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final ValueNotifier<bool> _canPop = ValueNotifier<bool>(false);
  String? _groupId; // null means non-group (personal) expense context

  void _onBack() {
    _canPop.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<GroupDetailBloc>().state;
        Navigator.pop(context, state.hasChanges);
      }
    });
  }

  @override
  void dispose() {
    _canPop.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _groupId = args?["group_id"] as String?;
      setState(() {}); // rebuild with resolved groupId
      context.read<GroupDetailBloc>().add(LoadGroupDetails(groupId: _groupId));
      context.read<GroupDetailBloc>().add(LoadGroupExpenseHistory(groupId: _groupId));
    });
    super.initState();
  }

  /// Open the Add Expense page and reload expense history when expense is saved.
  Future<void> _openAddExpense() async {
    final state = context.read<GroupDetailBloc>().state;
    if (state.groupEntity != null) {
      NavigationUtils.handleResult(
        context: context,
        navigation: NavigationService.pushNamed(
          AppRoutes.addExpense,
          args: {
            'group': state.groupEntity,
            'origin': ExpenseOrigin.group,
          },
        ),
        refreshType: RefreshType.groupDetail,
        id: state.groupEntity!.id,
        onRefresh: () {
          context.read<GroupDetailBloc>().add(const LoadGroupDetails(hasChanges: true));
          context.read<GroupDetailBloc>().add(const LoadGroupExpenseHistory());
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataRefreshCubit, DataRefreshState>(
      listenWhen: (prev, curr) => curr.lastSignal?.type == RefreshType.groupDetail,
      listener: (context, state) {
        final groupId = context.read<GroupDetailBloc>().state.groupEntity?.id;
        if (context.read<DataRefreshCubit>().shouldRefresh(RefreshType.groupDetail, id: groupId)) {
          context.read<DataRefreshCubit>().clearRefresh(RefreshType.groupDetail, id: groupId);
          context.read<GroupDetailBloc>().add(const LoadGroupDetails(hasChanges: true));
          context.read<GroupDetailBloc>().add(const LoadGroupExpenseHistory());
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
        useSafeArea: false,
        backgroundColor: AppColors.backgroundLightGrey,
        floatingActionButton: _groupId == null
            ? null // No FAB for non-group context
            : BlocBuilder<GroupDetailBloc, GroupDetailState>(
                builder: (context, state) {
                  final hasMembers = (state.groupEntity?.members?.length ?? 0) > 1;
                  if (!hasMembers) return const SizedBox.shrink();

                  return FloatingActionButton.extended(
                    onPressed: _openAddExpense,
                    backgroundColor: AppColors.primaryTeal,
                    icon: const Icon(Icons.receipt_long, color: Colors.white),
                    label: Text(
                      "Add expense",
                      style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
        child: CustomRefreshIndicator(
          onRefresh: () async {
            context.read<GroupDetailBloc>().add(LoadGroupExpenseHistory());
          },
          child: CustomScrollView(
            slivers: [
              _GroupDetailAppBar(onBack: _onBack, isNonGroup: _groupId == null),
              // 1. Group info & Balance summary
              BlocBuilder<GroupDetailBloc, GroupDetailState>(
                builder: (context, state) {
                  final isLoading = state.status == GroupDetailStatus.loading || state.status == GroupDetailStatus.initial;
                  final hasGroup = state.groupEntity != null;
                  
                  // Allow group info panel for non-group context to show overall balance

                  // Show shimmer while group is loading
                  if (isLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _ShimmerDetailInfo(),
                      ),
                    );
                  }

                  // Hide if no group AND it's not a non-group context
                  if (!hasGroup && _groupId != null) return const SliverToBoxAdapter(child: SizedBox());

                  // Show info iff we have members or if we have historical expenses
                  final hasMembers = _groupId == null || (state.groupEntity?.members?.length ?? 0) > 1;
                  final hasExpenses = (state.expenseHistory?.expenses?.isNotEmpty ?? false);
                  if (!hasMembers && !hasExpenses) return const SliverToBoxAdapter(child: SizedBox());

                  return _GroupDetailInfo(isNonGroup: _groupId == null);
                },
              ),

              // 2. Transaction List / Empty States
              BlocBuilder<GroupDetailBloc, GroupDetailState>(
                builder: (context, state) {
                  // Show shimmer only while expense history is actively loading (or before first load)
                  final isHistoryLoading = state.expenseStatus == GroupDetailExpenseStatus.loading ||
                                          state.expenseStatus == GroupDetailExpenseStatus.initial;

                  if (isHistoryLoading) {
                    return const _ShimmerTransactionList();
                  }

                  if (state.expenseStatus == GroupDetailExpenseStatus.failure) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            state.expenseErrorMessage ?? "Failed to load expenses",
                            style: GoogleFonts.openSans(color: AppColors.errorRed, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state.expenseStatus == GroupDetailExpenseStatus.success &&
                      state.expenseHistory != null) {
                    // For non-group: skip member count check entirely — always show expenses
                    final hasMembers = _groupId == null ||
                        (state.groupEntity?.members?.length ?? 0) > 1;
                    return _TransactionList(
                      expenses: state.expenseHistory?.expenses ?? [],
                      hasMembers: hasMembers,
                      groupId: _groupId,
                      isNonGroup: _groupId == null,
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100))
            ],
          ),
        ),
      ),
        );
      },
    ),
  );
}
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton widgets (using skeletonizer)
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton for the whole detail info box
class _ShimmerDetailInfo extends StatelessWidget {
  const _ShimmerDetailInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGreyLight),
      ),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FakeLine(width: 240, height: 18),
            const SizedBox(height: 10),
            _FakeLine(width: 190, height: 14),
            const SizedBox(height: 24),
            Row(
              children: [
                Bone.square(size: 80, borderRadius: BorderRadius.circular(12)),
                const SizedBox(width: 12),
                Bone.square(size: 80, borderRadius: BorderRadius.circular(12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// A fake text-like rectangle used inside skeleton placeholders
class _FakeLine extends StatelessWidget {
  final double width;
  final double height;
  const _FakeLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Bone.text(
      width: width,
      fontSize: height,
    );
  }
}

/// Skeleton for a single transaction row
class _ShimmerTransactionItem extends StatelessWidget {
  const _ShimmerTransactionItem();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Date column
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Bone.text(width: 28, fontSize: 12),
                  const SizedBox(height: 4),
                  Bone.text(width: 22, fontSize: 18),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Icon placeholder
            Bone.square(size: 44, borderRadius: BorderRadius.circular(8)),
            const SizedBox(width: 16),
            // Description + sub-text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(width: double.infinity, fontSize: 16),
                  const SizedBox(height: 6),
                  Bone.text(width: 150, fontSize: 12),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Balance column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Bone.text(width: 56, fontSize: 12),
                const SizedBox(height: 4),
                Bone.text(width: 64, fontSize: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A full sliver list of shimmer rows with a month-header skeleton on top
class _ShimmerTransactionList extends StatelessWidget {
  const _ShimmerTransactionList();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header skeleton
          Skeletonizer(
            enabled: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Bone.text(width: 110, fontSize: 14),
            ),
          ),
          // 5 fake transaction rows
          for (int i = 0; i < 5; i++) const _ShimmerTransactionItem(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Existing Widgets (unchanged except _BalanceSummary loading state)
// ─────────────────────────────────────────────────────────────────────────────

class _GroupDetailInfo extends StatelessWidget {
  final bool isNonGroup;

  const _GroupDetailInfo({this.isNonGroup = false});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGreyLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BalanceSummary(),
              if (!isNonGroup) ...[
                const SizedBox(height: 16),
                const _ActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class _GroupDetailAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool isNonGroup;
  const _GroupDetailAppBar({required this.onBack, this.isNonGroup = false});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      pinned: true,
      backgroundColor: Colors.transparent,
      leadingWidth: 80,
      leading: AppBackButton(
        onPressed: onBack,
        color: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.3),
      ),
      actions: [
        if (!isNonGroup)
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () async {
            final state = context.read<GroupDetailBloc>().state;
            if (state.groupEntity?.id != null) {
              final result = await NavigationService.pushNamed(
                AppRoutes.groupSettings,
                args: {'groupId': state.groupEntity!.id!},
              );

              if (!context.mounted) return;

              if (result == 'refresh-and-pop') {
                // Return true to GroupsPage so it refreshes its list
                Navigator.pop(context, true);
              } else {
                NavigationUtils.handleResult(
                  context: context,
                  navigation: Future.value(result),
                  refreshType: RefreshType.groupDetail,
                  id: state.groupEntity!.id,
                  onRefresh: () {
                    context.read<GroupDetailBloc>().add(const LoadGroupDetails(hasChanges: true));
                  },
                );
              }
            }
          },
        ),
          ),
      ],
      flexibleSpace: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          final groupEntity = state.groupEntity;

          return LayoutBuilder(
            builder: (context, constraints) {
              const double expandedHeight = 180.0;
              final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
              final double currentHeight = constraints.maxHeight;
              
              // t ranges from 0.0 (collapsed) to 1.0 (expanded)
              final double t = ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
              
              // Animations
              final double titleSizes = Tween<double>(begin: 20.0, end: 28.0).transform(t);
              final double titleLeft = Tween<double>(begin: 50.0, end: 20.0).transform(t);
              final double titleBottom = Tween<double>(begin: 14.0, end: 58.0).transform(t);
              final double memberOpacity = Tween<double>(begin: 0.0, end: 1.0).transform((t - 0.5).clamp(0.0, 0.5) * 2);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background Image (Persistent)
                  if (groupEntity?.groupIcon != null)
                     Hero(
                        tag: groupEntity!.id!,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(groupEntity.groupIcon!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                     )
                  else
                    Container(color: AppColors.primaryTeal),
                  
                  // 2. Gradient (Persistent)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),

                  // 3. Title Animation
                  Positioned(
                    left: titleLeft,
                    bottom: titleBottom,
                    child: Text(
                      groupEntity?.name ?? "",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: titleSizes,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // 4. Member Count pill — hidden in non-group context
                  if (!isNonGroup)
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Opacity(
                        opacity: memberOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_outline, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "${groupEntity?.members?.length ?? 0} people",
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailBloc, GroupDetailState>(
      builder: (context, state) {
        final history = state.expenseHistory;
        final isHistoryLoading = state.expenseStatus == GroupDetailExpenseStatus.loading;

        // ── Skeletonizer for the balance section ──
        if (isHistoryLoading) {
          return Skeletonizer(
            enabled: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FakeLine(width: 240, height: 18),
                const SizedBox(height: 10),
                _FakeLine(width: 190, height: 14),
                const SizedBox(height: 16),
                _FakeLine(width: double.infinity, height: 56),
              ],
            ),
          );
        }

        if (history == null) return const SizedBox();

        final double overall = history.overallBalance;
        final bool youAreOwed = history.youAreOwed?? false;
        final formatter = NumberFormat('#,##0.##', 'en_IN');
        final balanceColor = overall == 0
            ? AppColors.textGrey
            : (youAreOwed ? AppColors.successGreen : AppColors.errorRed);
        final overallLabel = overall == 0
            ? "You are fully settled up in this group"
            : (youAreOwed ? "You are owed" : "You owe");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Overall headline ──────────────────────────
            RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textBlack),
                children: [
                  TextSpan(text: overallLabel),
                  if (overall != 0) ...
                    [
                      const TextSpan(text: " "),
                      TextSpan(
                        text: '₹${formatter.format(overall.abs())}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: balanceColor),
                      ),
                      const TextSpan(text: " overall"),
                    ],
                ],
              ),
            ),

            ],
          );
        },
      );
    }
  }

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildActionButton(
            label: "Settle up",
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            onPressed: () {
              final state = context.read<GroupDetailBloc>().state;
              if (state.expenseHistory?.memberBalances != null) {
                NavigationService.pushNamed(
                  AppRoutes.settleUpSelection,
                  args: {
                    'balances': state.expenseHistory!.memberBalances,
                    'groupId': state.groupEntity?.id,
                  },
                );
              }
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: "Balances",
            icon: Icons.bar_chart_rounded,
            color: AppColors.textBlack,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: "Totals",
            icon: Icons.functions_rounded,
            color: AppColors.textBlack,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGreyLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<GroupExpenseEntity> expenses;
  final bool hasMembers;
  final String? groupId;
  final bool isNonGroup;

  const _TransactionList({
    required this.expenses,
    this.hasMembers = true,
    this.groupId,
    this.isNonGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    // In non-group context we skip the member-count gate entirely
    if (!isNonGroup && !hasMembers && expenses.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    size: 72,
                    color: AppColors.warningOrange,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Only you are here!",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You can't add an expense because you don't have any members in the group yet.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (groupId != null) {
                      NavigationUtils.handleResult(
                        context: context,
                        navigation: NavigationService.pushNamed(
                          AppRoutes.addMembers,
                          args: {'groupId': groupId!},
                        ),
                        refreshType: RefreshType.groupDetail,
                        id: groupId,
                        onRefresh: () {
                          context.read<GroupDetailBloc>().add(const LoadGroupDetails(hasChanges: true));
                          context.read<GroupDetailBloc>().add(const LoadGroupExpenseHistory());
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.group_add_rounded, color: Colors.white),
                  label: const Text("Add Members"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (expenses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 64),
          child: AppEmptyState(
            icon: Icons.receipt_long_rounded,
            title: "No expenses yet",
            subtitle: "Add the first expense to start splitting costs in this group.",
          ),
        ),
      );
    }

    // Group by date header
    final Map<String, List<GroupExpenseEntity>> grouped = {};
    for (final expense in expenses) {
      try {
        final date = DateTime.parse(expense.createdAt);
        final header = DateFormat('MMMM yyyy').format(date);
        grouped.putIfAbsent(header, () => []).add(expense);
      } catch (_) {
        grouped.putIfAbsent('Unknown', () => []).add(expense);
      }
    }

    final List<Widget> children = [];
    for (final entry in grouped.entries) {
      // Month header
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            entry.key,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
      for (final expense in entry.value) {
        children.add(_TransactionItem(expense: expense, groupId: groupId));
      }
    }

    return SliverList(
      delegate: SliverChildListDelegate(children),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final GroupExpenseEntity expense;
  final String? groupId;

  const _TransactionItem({required this.expense, this.groupId});

  @override
  Widget build(BuildContext context) {
    DateTime? date;
    String month = '';
    String day = '';
    try {
      date = DateTime.parse(expense.createdAt);
      month = DateFormat('MMM').format(date).toUpperCase();
      day = DateFormat('d').format(date);
    } catch (_) {}

    final bool isSettlement = expense.type == 'settlement';
    final bool youLent = expense.yourBalanceEffect > 0;
    final bool involved = expense.yourBalanceEffect != 0;

    final Color balanceColor = youLent ? AppColors.successGreen : AppColors.errorRed;
    final String balanceLabel = isSettlement 
        ? (youLent ? 'you paid' : 'you received')
        : (youLent ? 'you lent' : 'you owe');
    final formatter = NumberFormat('#,##0.##', 'en_IN');

    final IconData iconData = isSettlement ? Icons.handshake_rounded : Icons.receipt_long_rounded;
    final Color iconColor = isSettlement ? AppColors.successGreen : AppColors.primaryTeal;
    final Color iconBgColor = isSettlement ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.primaryTeal.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: () {
        NavigationUtils.handleResult(
          context: context,
          navigation: NavigationService.pushNamed(
            AppRoutes.expanseDetail,
            args: {"expanse_id": expense.expenseId},
          ),
          refreshType: RefreshType.groupDetail,
          id: groupId,
          onRefresh: () {
            context.read<GroupDetailBloc>().add(const LoadGroupDetails(hasChanges: true));
            context.read<GroupDetailBloc>().add(const LoadGroupExpenseHistory());
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Row(
              children: [
                // Date column
                SizedBox(
                  width: 38,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(month, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      Text(
                        day,
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textBlack, height: 1.1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Description + paid by
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSettlement ? "${expense.paidByName} paid" : expense.description,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSettlement
                            ? "₹${formatter.format(expense.totalAmount)} exchanged"
                            : "${expense.paidByName} paid ₹${formatter.format(expense.totalAmount)}",
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Balance effect
                if (!involved)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("not involved", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(balanceLabel, style: GoogleFonts.outfit(fontSize: 12, color: balanceColor, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        "₹${formatter.format(expense.yourBalanceEffect.abs())}",
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: balanceColor, letterSpacing: -0.5),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
