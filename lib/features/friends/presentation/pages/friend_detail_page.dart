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
import 'package:split_ease/features/expenses/presentation/pages/expense_detail_page.dart';
import 'package:intl/intl.dart';

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
    // Add Expense logic
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
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddExpense,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: Text(
            "Add expense",
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        child: CustomRefreshIndicator(
          onRefresh: () async {
            context.read<FriendDetailBloc>().add(const LoadFriendExpenseHistory());
          },
          child: CustomScrollView(
            slivers: [
              _FriendDetailAppBar(onBack: _onBack),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      BlocBuilder<FriendDetailBloc, FriendDetailState>(
                        builder: (context, state) {
                          if (state.friendEntity == null) return const SizedBox();
                          return _FriendDetailInfo(state.friendEntity!);
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: AppColors.backgroundLightGrey),
                    ],
                  ),
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

class _ShimmerBalanceSummary extends StatelessWidget {
  const _ShimmerBalanceSummary();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(width: 240, fontSize: 18),
          const SizedBox(height: 10),
          Bone.text(width: 190, fontSize: 14),
          const SizedBox(height: 6),
          Bone.text(width: 160, fontSize: 14),
        ],
      ),
    );
  }
}

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

class _FriendDetailAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const _FriendDetailAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: BlocBuilder<FriendDetailBloc, FriendDetailState>(
        builder: (context, state) {
          final friendEntity = state.friendEntity;

          return LayoutBuilder(
            builder: (context, constraints) {
              const double expandedHeight = 220.0;
              final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
              final double currentHeight = constraints.maxHeight;

              final double t = ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

              final double titleSizes = Tween<double>(begin: 20.0, end: 32.0).transform(t);
              final double titleLeft = Tween<double>(begin: 48.0, end: 24.0).transform(t);
              final double titleBottom = Tween<double>(begin: 14.0, end: 24.0).transform(t);

              final double avatarSize = Tween<double>(begin: 0.0, end: 64.0).transform(t);
              final double avatarBottom = Tween<double>(begin: 60.0, end: 68.0).transform(t);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Dark Teal solid background 
                  Container(color: AppColors.primary),
                  // Subtle Grid/Gradient Overlay
                  Positioned(
                    left: -100,
                    top: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  // Avatar
                  if (t > 0.1)
                    Positioned(
                      left: 24,
                      bottom: avatarBottom,
                      child: Hero(
                        tag: friendEntity?.id ?? 'friend_avatar',
                        child: Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            image: friendEntity?.imageUrl != null
                                ? DecorationImage(image: CachedNetworkImageProvider(friendEntity!.imageUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: friendEntity?.imageUrl == null ? Icon(Icons.person, color: Colors.white, size: avatarSize * 0.5) : null,
                        ),
                      ),
                    ),

                  // Title
                  Positioned(
                    left: titleLeft,
                    bottom: titleBottom,
                    child: Text(
                      friendEntity?.name ?? "",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: titleSizes, fontWeight: FontWeight.w700, letterSpacing: -0.5),
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

class _FriendDetailInfo extends StatelessWidget {
  final FriendEntity friend;

  const _FriendDetailInfo(this.friend);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BalanceSummary(), 
          const SizedBox(height: 24), 
          const _ActionButtons(),
        ],
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendDetailBloc, FriendDetailState>(
      buildWhen: (previous, current) => previous.friendEntity != current.friendEntity || previous.expenseStatus != current.expenseStatus,
      builder: (context, state) {
        final friend = state.friendEntity;
        if (friend == null) return const SizedBox();

        if (state.expenseStatus == FriendDetailExpenseStatus.loading) {
          return const _ShimmerBalanceSummary();
        }

        final formatter = NumberFormat('#,##0.##', 'en_IN');

        // Overall
        final bool youAreOwed = state.expenseHistory?.status == 'you_are_owed';
        final double absOverall = friend.overallBalance.abs();
        final Color overallColor = youAreOwed ? AppColors.successGreen : AppColors.errorRed;
        String overallLabel = friend.overallBalance == 0 ? "You are settled up" : (youAreOwed ? "Gets back" : "Owes");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (friend.overallBalance != 0) ...[
               Text(
                 "Overall Balance",
                 style: GoogleFonts.outfit(color: AppColors.iconGrey, fontSize: 13, fontWeight: FontWeight.w500),
               ),
               const SizedBox(height: 4),
               Row(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   Text(
                     "₹${formatter.format(absOverall)}",
                     style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: overallColor, letterSpacing: -1),
                   ),
                   const SizedBox(width: 8),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: overallColor.withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Text(
                       overallLabel,
                       style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: overallColor),
                     ),
                   ),
                 ],
               ),
            ] else ...[
               Text(
                 "Overall Balance",
                 style: GoogleFonts.outfit(color: AppColors.iconGrey, fontSize: 13, fontWeight: FontWeight.w500),
               ),
               const SizedBox(height: 4),
               Text(
                 overallLabel,
                 style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textBlack),
               ),
            ],
            
            if (friend.groupBreakdown.isNotEmpty || friend.nonGroupBalance != 0) ...[
              const SizedBox(height: 24),
              Text(
                "Breakdown",
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey, letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
            ],

            // Nested group breakdowns
            ...friend.groupBreakdown.take(3).map((g) {
              final bool gOwed = g.balance > 0;
              final Color gColor = gOwed ? AppColors.successGreen : AppColors.warningOrange;
              final String? name = friend.name.split(' ').firstOrNull;
              final String gText = gOwed ? "$name owes you" : "You owe $name";

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.backgroundLightGrey,
                      ),
                      child: const Icon(Icons.groups_rounded, size: 16, color: AppColors.iconGrey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.groupName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack)),
                          Text(gText, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    Text(
                      "₹${formatter.format(g.balance.abs())}",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: gColor),
                    ),
                  ],
                ),
              );
            }),

            // Non-group breakdown
            if (friend.nonGroupBalance != 0) ...[
              Builder(
                builder: (context) {
                  final bool ngOwed = friend.nonGroupBalance > 0;
                  final Color ngColor = ngOwed ? AppColors.successGreen : AppColors.warningOrange;
                  final String name = friend.name.split(' ').first;
                  final String ngText = ngOwed ? "$name owes you" : "You owe $name";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.backgroundLightGrey,
                          ),
                          child: const Icon(Icons.person_rounded, size: 16, color: AppColors.iconGrey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Non-group", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack)),
                              Text(ngText, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                        Text(
                          "₹${formatter.format(friend.nonGroupBalance.abs())}",
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: ngColor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],

            if (friend.groupBreakdown.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "+ ${friend.groupBreakdown.length - 3} more balances",
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textGrey),
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
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildPillBtn("Settle up", AppColors.warningOrange, Colors.white, () {}, isSolid: true),
          const SizedBox(width: 12),
          _buildPillBtn("Remind...", Colors.transparent, AppColors.textBlack, () {}, isSolid: false),
          const SizedBox(width: 12),
          _buildPillBtn("Charts", Colors.transparent, AppColors.textBlack, () {}, isSolid: false, icon: Icons.pie_chart_rounded, iconColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildPillBtn(String label, Color bgColor, Color textColor, VoidCallback onTap, {required bool isSolid, IconData? icon, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: isSolid ? null : Border.all(color: AppColors.borderGreyLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
               Icon(icon, color: iconColor ?? textColor, size: 16),
               const SizedBox(width: 6),
            ],
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
          ],
        ),
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: AppColors.backgroundLightGrey, shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.iconGrey),
                ),
                const SizedBox(height: 24),
                Text(
                  "No expenses yet",
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
    for (final entry in grouped.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
          child: Text(
            entry.key.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.iconGrey, letterSpacing: 1.0),
          ),
        ),
      );
      for (final expense in entry.value) {
        children.add(_TransactionItem(expense: expense));
      }
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
        NavigationService.pushNamed(AppRoutes.expanseDetail,args: {"expanse_id":expense.expenseId});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.iconGrey),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.backgroundLightGrey,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGreyLight, width: 0.5),
                image: expense.groupIcon != null
                    ? DecorationImage(image: CachedNetworkImageProvider(expense.groupIcon!), fit: BoxFit.cover)
                    : null,
              ),
              child: expense.groupIcon == null ? const Icon(Icons.receipt_long_rounded, color: AppColors.textGrey, size: 20) : null,
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
                  const SizedBox(height: 2),
                  Text(
                    expense.groupName != null ? 'in "${expense.groupName}"' : "Non-group expense",
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textGrey),
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
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: balanceColor),
                ),
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
