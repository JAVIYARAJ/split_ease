import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_expense_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_balance_entity.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:split_ease/features/groups/presentation/pages/group_settings_page.dart';

import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:intl/intl.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  bool _canPop = false;

  void _onBack() {
    setState(() {
      _canPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<GroupDetailBloc>().state;
        Navigator.pop(context, state.hasChanges);
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args?["group_id"] != null) {
        context.read<GroupDetailBloc>().add(LoadGroupDetails(groupId: args?["group_id"]));
        context.read<GroupDetailBloc>().add(LoadGroupExpenseHistory(groupId: args?["group_id"]));
      }
    });
    super.initState();
  }

  /// Open the Add Expense page and reload expense history when expense is saved.
  Future<void> _openAddExpense() async {
    final state = context.read<GroupDetailBloc>().state;
    if (state.groupEntity != null) {
      final result = await NavigationService.pushNamed(
        AppRoutes.addExpense,
        args: {'group': state.groupEntity},
      );
      // AddExpensePage pops with `true` on success → reload history
      if (result == true && mounted) {
        context.read<GroupDetailBloc>().add(LoadGroupExpenseHistory());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBack();
      },
      child: BaseScreen(
        useSafeArea: false,
        backgroundColor: AppColors.backgroundWhite,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddExpense,
          backgroundColor: AppColors.primaryTeal,
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: Text(
            "Add expense",
            style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        child: CustomRefreshIndicator(
          onRefresh: () async {
            context.read<GroupDetailBloc>().add(LoadGroupExpenseHistory());
          },
          child: CustomScrollView(
            slivers: [
              _GroupDetailAppBar(onBack: _onBack),
              BlocBuilder<GroupDetailBloc, GroupDetailState>(
                builder: (context, state) {
                  if (state.groupEntity == null) return const SliverToBoxAdapter(child: SizedBox());
                  return _GroupDetailInfo(state.groupEntity!);
                },
              ),
              BlocBuilder<GroupDetailBloc, GroupDetailState>(
                builder: (context, state) {
                  if (state.expenseStatus == GroupDetailExpenseStatus.loading) {
                    return _ShimmerTransactionList();
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
                    return _TransactionList(expenses: state.expenseHistory?.expenses??[]);
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              SliverToBoxAdapter(child: SizedBox(
                height: 100,
              ))
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton widgets (using skeletonizer)
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton for the balance summary section
class _ShimmerBalanceSummary extends StatelessWidget {
  const _ShimmerBalanceSummary();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall balance line (wide)
          _FakeLine(width: 240, height: 18),
          const SizedBox(height: 10),
          // Member balance lines
          _FakeLine(width: 190, height: 14),
          const SizedBox(height: 6),
          _FakeLine(width: 160, height: 14),
        ],
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
    return Padding(
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
    );
  }
}

/// A full sliver list of shimmer rows with a month-header skeleton on top
class _ShimmerTransactionList extends StatelessWidget {
  const _ShimmerTransactionList();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Bone.text(width: 110, fontSize: 14),
            ),
            // 5 fake transaction rows
            for (int i = 0; i < 5; i++) const _ShimmerTransactionItem(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Existing Widgets (unchanged except _BalanceSummary loading state)
// ─────────────────────────────────────────────────────────────────────────────

class _GroupDetailInfo extends StatelessWidget {
  final GroupEntity group;

  const _GroupDetailInfo(this.group);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BalanceSummary(),
            const SizedBox(height: 24),
            const _ActionButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


class _GroupDetailAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _GroupDetailAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: onBack,
      ),
      actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
            final state = context.read<GroupDetailBloc>().state;
            if (state.groupEntity?.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsPage(groupId: state.groupEntity!.id!),
                ),
              ).then((value) {
                if(value == true && context.mounted){
                   context.read<GroupDetailBloc>().add(LoadGroupDetails( hasChanges: true));
                }
              });
            }
          },
        ),
      ],
      flexibleSpace: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          final groupEntity = state.groupEntity;

          return LayoutBuilder(
            builder: (context, constraints) {
              const double expandedHeight = 200.0;
              final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
              final double currentHeight = constraints.maxHeight;
              
              // t ranges from 0.0 (collapsed) to 1.0 (expanded)
              final double t = ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
              
              // Animations
              final double titleSizes = Tween<double>(begin: 20.0, end: 28.0).transform(t);
              final double titleLeft = Tween<double>(begin: 50.0, end: 20.0).transform(t);
              final double titleBottom = Tween<double>(begin: 14.0, end: 55.0).transform(t);
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),

                  // 3. Title Animation
                  Positioned(
                    left: titleLeft,
                    bottom: titleBottom,
                    child: Text(
                      groupEntity?.name ?? "",
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: titleSizes,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 4. Member Count (Fades out)
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
                              style: GoogleFonts.openSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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
      buildWhen: (previous, current) => previous.expenseHistory != current.expenseHistory || previous.expenseStatus != current.expenseStatus,
      builder: (context, state) {
        final history = state.expenseHistory;

        // ── Skeletonizer for the balance section ──
        if (state.expenseStatus == GroupDetailExpenseStatus.loading) {
          return const _ShimmerBalanceSummary();
        }

        if (history == null) return const SizedBox();

        final bool youAreOwed = history.youAreOwed;
        final double overall = history.overallBalance;
        final balanceColor = youAreOwed ? AppColors.successGreen : AppColors.errorRed;
        final overallLabel = youAreOwed ? "You are owed" : "You owe";
        final memberLabel = youAreOwed ? "owes you" : "you owe";
        final formatted = _formatCurrency(overall);
        final List<GroupMemberBalanceEntity> memberBalances = history.memberBalances ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack),
                children: [
                  TextSpan(text: "$overallLabel "),
                  TextSpan(
                    text: formatted,
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: balanceColor),
                  ),
                  const TextSpan(text: " overall"),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...memberBalances.map(
              (m) => _buildBalanceLine(
                m.fullName,
                _formatCurrency(m.balance),
                memberLabel,
                balanceColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceLine(String name, String amount, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textGrey),
          children: [
            TextSpan(text: "$name $label "),
            TextSpan(
              text: amount,
              style: GoogleFonts.openSans(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.##', 'en_IN');
    return '₹${formatter.format(amount)}';
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
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Settle up", style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Balances", style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Totals", style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<GroupExpenseEntity> expenses;

  const _TransactionList({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
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
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 72,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No expenses yet",
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "This group needs some action.\nAdd a new expense to start splitting!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
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
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
        ),
      );
      for (final expense in entry.value) {
        children.add(_TransactionItem(expense: expense));
      }
    }

    return SliverList(
      delegate: SliverChildListDelegate(children),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final GroupExpenseEntity expense;

  const _TransactionItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    DateTime? date;
    String month = '';
    String day = '';
    try {
      date = DateTime.parse(expense.createdAt);
      month = DateFormat('MMM').format(date);
      day = DateFormat('d').format(date);
    } catch (_) {}

    final bool youLent = expense.type == 'you_lent';
    final Color balanceColor = youLent ? AppColors.successGreen : AppColors.errorRed;
    final String balanceLabel = youLent ? 'you lent' : 'you owe';
    final formatter = NumberFormat('#,##0.##', 'en_IN');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Date column
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Text(month, style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textGrey)),
                Text(
                  day,
                  style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.receipt_long_outlined, color: AppColors.textGrey),
          ),
          const SizedBox(width: 16),
          // Description + paid by
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${expense.paidByName} paid ₹${formatter.format(expense.totalAmount)}",
                  style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          // Balance effect
          if (expense.yourBalanceEffect == 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Not involved", style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textGrey, fontStyle: FontStyle.italic)),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(balanceLabel, style: GoogleFonts.openSans(fontSize: 12, color: balanceColor)),
                Text(
                  "₹${formatter.format(expense.yourBalanceEffect)}",
                  style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: balanceColor),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
