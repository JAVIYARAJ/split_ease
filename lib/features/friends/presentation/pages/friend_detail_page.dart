import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_entity.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_bloc.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_event.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_state.dart';
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
    // Add Expense logic (if needed in friend scope)
    // Could pass friend object as argument to pre-populate payer/split
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
            context.read<FriendDetailBloc>().add(const LoadFriendExpenseHistory());
          },
          child: CustomScrollView(
            slivers: [
              _FriendDetailAppBar(onBack: _onBack),
              BlocBuilder<FriendDetailBloc, FriendDetailState>(
                builder: (context, state) {
                  if (state.friendEntity == null) return const SliverToBoxAdapter(child: SizedBox());
                  return _FriendDetailInfo(state.friendEntity!);
                },
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
                            style: GoogleFonts.openSans(color: AppColors.errorRed, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  if (state.expenseStatus == FriendDetailExpenseStatus.success &&
                      state.expenseHistory != null) {
                    return _TransactionList(expenses: state.expenseHistory?.expenses ?? []);
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100))
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
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
          Bone.square(size: 44, borderRadius: BorderRadius.circular(8)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Bone.text(width: 110, fontSize: 14),
            ),
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
            // Friend Settings placeholder
          },
        ),
      ],
      flexibleSpace: BlocBuilder<FriendDetailBloc, FriendDetailState>(
        builder: (context, state) {
          final friendEntity = state.friendEntity;

          return LayoutBuilder(
            builder: (context, constraints) {
              const double expandedHeight = 200.0;
              final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
              final double currentHeight = constraints.maxHeight;
              
              final double t = ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
              
              final double titleSizes = Tween<double>(begin: 20.0, end: 28.0).transform(t);
              final double titleLeft = Tween<double>(begin: 50.0, end: 20.0).transform(t);
              final double titleBottom = Tween<double>(begin: 14.0, end: 55.0).transform(t);
              
              // Move avatar upwards and scale
              final double avatarSize = Tween<double>(begin: 0.0, end: 64.0).transform(t);
              final double avatarBottom = Tween<double>(begin: 60.0, end: 95.0).transform(t);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background geometric or solid color (match screenshot style)
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTeal,
                      image: DecorationImage(
                        image: AssetImage('assets/images/pattern_header.png'), // Might not exist, fallback to color
                        fit: BoxFit.cover,
                        opacity: 0.3,
                      ),
                    ),
                  ),
                  
                  // 2. Title Animation
                  Positioned(
                    left: titleLeft,
                    bottom: titleBottom,
                    child: Text(
                      friendEntity?.name ?? "",
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: titleSizes,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 3. Avatar Animation
                  if (t > 0.1) // hide when collapsed
                    Positioned(
                      left: 20,
                      bottom: avatarBottom,
                      child: Hero(
                        tag: friendEntity?.id ?? 'friend_avatar',
                        child: Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.warningOrange, // From screenshot
                            border: Border.all(color: Colors.white, width: 3),
                            image: friendEntity?.imageUrl != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(friendEntity!.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: friendEntity?.imageUrl == null
                              ? Icon(Icons.person, color: Colors.white, size: avatarSize * 0.5)
                              : null,
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

class _FriendDetailInfo extends StatelessWidget {
  final FriendEntity friend;

  const _FriendDetailInfo(this.friend);

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
        String overallLabel = friend.overallBalance == 0 ? "You are settled up" : (youAreOwed ? "You are owed" : "You owe");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack),
                children: [
                  if (friend.overallBalance != 0) ...[
                    TextSpan(text: "$overallLabel ", style: GoogleFonts.openSans(color: overallColor, fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: "₹${formatter.format(absOverall)}",
                      style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: overallColor),
                    ),
                    TextSpan(text: " overall", style: GoogleFonts.openSans(color: overallColor, fontWeight: FontWeight.bold)),
                  ] else ...[
                     TextSpan(text: overallLabel, style: GoogleFonts.openSans(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Nested group breakdowns
            ...friend.groupBreakdown.take(3).map((g) {
              final bool gOwed = g.balance > 0;
              final Color gColor = gOwed ? AppColors.successGreen : AppColors.warningOrange; // Matching screenshot orange for owe
              final String? name = friend.name.split(' ').firstOrNull;
              final String gText = gOwed ? "$name owes you" : "You owe $name";

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textBlack),
                    children: [
                      TextSpan(text: "$gText "),
                      TextSpan(
                        text: "₹${formatter.format(g.balance.abs())} ",
                        style: GoogleFonts.openSans(fontWeight: FontWeight.w600, color: gColor),
                      ),
                      TextSpan(text: 'in "${g.groupName}"', style: GoogleFonts.openSans(color: AppColors.textGrey)),
                    ],
                  ),
                ),
              );
            }),

            // Non-group breakdown
            if (friend.nonGroupBalance != 0) ...[
              Builder(builder: (context) {
                final bool ngOwed = friend.nonGroupBalance > 0;
                final Color ngColor = ngOwed ? AppColors.successGreen : AppColors.warningOrange;
                final String name = friend.name.split(' ').first;
                final String ngText = ngOwed ? "$name owes you" : "You owe $name";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textBlack),
                      children: [
                        TextSpan(text: "$ngText "),
                        TextSpan(
                          text: "₹${formatter.format(friend.nonGroupBalance.abs())} ",
                          style: GoogleFonts.openSans(fontWeight: FontWeight.w600, color: ngColor),
                        ),
                        TextSpan(text: 'in non-group expenses', style: GoogleFonts.openSans(color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                );
              }),
            ],

             if (friend.groupBreakdown.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                   "Plus ${friend.groupBreakdown.length - 3} more balances",
                   style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textGrey),
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
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textBlack,
              side: const BorderSide(color: Colors.black12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Remind...", style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textBlack,
              side: const BorderSide(color: Colors.black12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.purple, size: 18),
                const SizedBox(width: 6),
                Text("Charts", style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          ),
        ],
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
                  "Add a new expense with this friend to start splitting!",
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
    final Color balanceColor = youAreOwed ? AppColors.successGreen : AppColors.errorRed; 
    final String balanceLabel = youAreOwed ? 'you are owed' : 'you owe';
    final formatter = NumberFormat('#,##0.##', 'en_IN');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.backgroundLightGrey, 
              borderRadius: BorderRadius.circular(8),
              image: expense.groupIcon != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(expense.groupIcon!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: expense.groupIcon == null
                ? const Icon(Icons.receipt_long_outlined, color: AppColors.textGrey)
                : null,
          ),
          const SizedBox(width: 16),
          // Description + group info
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
                  expense.groupName != null ? "Shared group" : "Non-group expense",
                  style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          // Balance effect
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(balanceLabel, style: GoogleFonts.openSans(fontSize: 12, color: balanceColor)),
              Text(
                "₹${formatter.format(expense.balanceEffect.abs())}",
                style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: balanceColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
