import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_entity.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_bloc.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_event.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_state.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';

class FriendDetailPage extends StatefulWidget {
  const FriendDetailPage({super.key});

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
  bool _canPop = false;

  void _onBack() {
    setState(() {
      _canPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<FriendDetailBloc>().state;
        Navigator.pop(context, state.hasChanges);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args?["friend"] != null) {
        context.read<FriendDetailBloc>().add(LoadFriendDetails(friend: args!["friend"] as FriendEntity));
      }
    });
  }

  Future<void> _openAddExpense() async {
    final state = context.read<FriendDetailBloc>().state;
    if (state.friendEntity != null) {
      final result = await NavigationService.pushNamed(
        AppRoutes.addExpense,
        args: {'friend': state.friendEntity},
      );
      // If the expense was added successfully, reload the history
      if (result == true && mounted) {
        context.read<FriendDetailBloc>().add(const LoadFriendExpenseHistory());
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
        backgroundColor: const Color(0xFFF9FAFB), // Very light airy background
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddExpense,
          backgroundColor: AppColors.primary,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            "Expense",
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        child: CustomRefreshIndicator(
          onRefresh: () async {
            context.read<FriendDetailBloc>().add(const LoadFriendExpenseHistory());
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
                pinned: true,
                backgroundColor: const Color(0xFFF9FAFB),
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack, size: 20),
                  onPressed: _onBack,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textBlack),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<FriendDetailBloc, FriendDetailState>(
                  builder: (context, state) {
                    if (state.friendEntity == null) return const SizedBox();
                    return _FriendDetailProfile(state.friendEntity!);
                  },
                ),
              ),
              BlocBuilder<FriendDetailBloc, FriendDetailState>(
                builder: (context, state) {
                  if (state.expenseStatus == FriendDetailExpenseStatus.loading) {
                    return const _ShimmerTransactionList();
                  }
                  if (state.expenseStatus == FriendDetailExpenseStatus.failure) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            state.expenseErrorMessage ?? "Failed to load expenses",
                            style: GoogleFonts.outfit(color: AppColors.errorRed, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  if (state.expenseStatus == FriendDetailExpenseStatus.success && state.expenseHistory != null) {
                    return _TransactionList(expenses: state.expenseHistory?.expenses ?? []);
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerTransactionItem extends StatelessWidget {
  const _ShimmerTransactionItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Column(children: [Bone.text(width: 28, fontSize: 12), const SizedBox(height: 4), Bone.text(width: 22, fontSize: 18)]),
          ),
          const SizedBox(width: 16),
          Bone.square(size: 40, borderRadius: BorderRadius.circular(20)),
          const SizedBox(width: 16),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Bone.text(width: 56, fontSize: 12), const SizedBox(height: 4), Bone.text(width: 64, fontSize: 14)],
          ),
        ],
      ),
    );
  }
}

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
            Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 8), child: Bone.text(width: 110, fontSize: 14)),
            for (int i = 0; i < 5; i++) const _ShimmerTransactionItem(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sections
// ─────────────────────────────────────────────────────────────────────────────

class _FriendDetailProfile extends StatelessWidget {
  final FriendEntity friend;

  const _FriendDetailProfile(this.friend);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Hero(
            tag: friend.id,
            child: AppAvatar(
              url: friend.imageUrl,
              radius: 55,
              iconSize: 48,
              backgroundColor: AppColors.backgroundLightGrey,
              iconColor: AppColors.iconGrey,
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
          const SizedBox(height: 20),

          // Name
          Text(
            friend.name,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Overall Balance Pill
          BlocBuilder<FriendDetailBloc, FriendDetailState>(
            builder: (context, state) {
              if (state.expenseStatus == FriendDetailExpenseStatus.loading) {
                return Skeletonizer(
                  enabled: true,
                  child: Bone.text(width: 120, fontSize: 24),
                );
              }

              final bool youAreOwed = state.expenseHistory?.status == 'you_are_owed';
              final double absOverall = friend.overallBalance.abs();
              final Color overallColor = friend.overallBalance == 0 ? AppColors.textGrey : (youAreOwed ? AppColors.successGreen : AppColors.errorRed);
              final formatter = NumberFormat('#,##0.##', 'en_IN');
              
              String prefix = friend.overallBalance == 0 ? "Settled up" : (youAreOwed ? "Gets back" : "Owes");
              String amount = friend.overallBalance == 0 ? "" : " ₹${formatter.format(absOverall)}";

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: overallColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: overallColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "$prefix$amount",
                  style: GoogleFonts.outfit(
                    color: overallColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircularAction(Icons.account_balance_wallet_rounded, "Settle Up", AppColors.warningOrange, () {}),
              const SizedBox(width: 24),
              _buildCircularAction(Icons.notifications_active_rounded, "Remind", AppColors.primary, () {}),
              const SizedBox(width: 24),
              _buildCircularAction(Icons.pie_chart_rounded, "Charts", const Color(0xFF6C63FF), () {}),
            ],
          ),

          const SizedBox(height: 36),
          
          // Breakdown Box
          if (friend.groupBreakdown.isNotEmpty || friend.nonGroupBalance != 0)
            const _BreakdownCard(),
        ],
      ),
    );
  }

  Widget _buildCircularAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textBlack),
        ),
      ],
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendDetailBloc, FriendDetailState>(
      builder: (context, state) {
        final friend = state.friendEntity;
        if (friend == null) return const SizedBox();
        final formatter = NumberFormat('#,##0.##', 'en_IN');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderGreyLight, width: 0.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_rounded, color: AppColors.iconGrey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Balance Breakdown",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ...friend.groupBreakdown.map((g) {
                final bool gOwed = g.balance > 0;
                final Color gColor = gOwed ? AppColors.successGreen : AppColors.errorRed;
                final String gText = gOwed ? "Owes you" : "You owe";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.groups_rounded, size: 20, color: AppColors.iconGrey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.groupName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textBlack)),
                            Text(gText, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Text(
                        "₹${formatter.format(g.balance.abs())}",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: gColor),
                      ),
                    ],
                  ),
                );
              }),

              if (friend.nonGroupBalance != 0) ...[
                Builder(
                  builder: (context) {
                    final bool ngOwed = friend.nonGroupBalance > 0;
                    final Color ngColor = ngOwed ? AppColors.successGreen : AppColors.errorRed;
                    final String ngText = ngOwed ? "Owes you" : "You owe";

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLightGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_rounded, size: 20, color: AppColors.iconGrey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Non-group", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textBlack)),
                                Text(ngText, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Text(
                            "₹${formatter.format(friend.nonGroupBalance.abs())}",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: ngColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<FriendExpenseEntity> expenses;

  const _TransactionList({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.iconGrey),
                ),
                const SizedBox(height: 20),
                Text(
                  "No Expenses Yet",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add a new expense with this friend to start splitting!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textGrey, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final Map<String, List<FriendExpenseEntity>> grouped = {};
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
    
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Text(
          "Recent Expenses",
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textBlack),
        ),
      ),
    );

    for (final entry in grouped.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 8),
          child: Text(
            entry.key.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.iconGrey, letterSpacing: 1.2),
          ),
        ),
      );
      
      final groupChildren = entry.value.map((expense) => _TransactionItem(expense: expense)).toList();
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGreyLight, width: 0.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < groupChildren.length; i++) ...[
                  groupChildren[i],
                  if (i < groupChildren.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 72.0),
                      child: Divider(height: 1, thickness: 0.5, color: AppColors.borderGreyLight),
                    ),
                ]
              ],
            ),
          ),
        ),
      );
      children.add(const SizedBox(height: 8));
    }

    return SliverList(delegate: SliverChildListDelegate(children));
  }
}

class _TransactionItem extends StatelessWidget {
  final FriendExpenseEntity expense;

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

    final bool youAreOwed = expense.type == 'you_are_owed';
    final Color balanceColor = youAreOwed ? AppColors.successGreen : AppColors.textGrey; 
    final String balanceLabel = youAreOwed ? 'Gets back' : 'Owes';
    final formatter = NumberFormat('#,##0.##', 'en_IN');

    return InkWell(
      onTap: () {
        NavigationService.pushNamed(AppRoutes.expanseDetail, args: {"expanse_id": expense.expenseId});
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    month.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.iconGrey),
                  ),
                  Text(
                    day,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textBlack),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.backgroundLightGrey,
                borderRadius: BorderRadius.circular(14),
                image: expense.groupIcon != null
                    ? DecorationImage(image: CachedNetworkImageProvider(expense.groupIcon!), fit: BoxFit.cover)
                    : null,
              ),
              child: expense.groupIcon == null ? const Icon(Icons.receipt_long_rounded, color: AppColors.iconGrey, size: 22) : null,
            ),
            const SizedBox(width: 16),
            // Description + group info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    expense.description,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.groupName != null ? 'In ${expense.groupName}' : "Non-group",
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Balance effect
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  balanceLabel,
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: balanceColor),
                ),
                const SizedBox(height: 2),
                Text(
                  "₹${formatter.format(expense.balanceEffect.abs())}",
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: balanceColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
