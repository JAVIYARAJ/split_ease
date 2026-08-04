import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:split_ease/core/presentation/widgets/app_empty_state.dart';
import 'package:split_ease/core/presentation/widgets/app_error_full_screen_dialog.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
import 'package:split_ease/core/theme/app_layout.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_entity.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_bloc.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_event.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_state.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/utils/navigation_utils.dart';
import 'package:intl/intl.dart';

class FriendDetailPage extends StatefulWidget {
  const FriendDetailPage({super.key});

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
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
      NavigationUtils.handleResult(
        context: context,
        navigation: NavigationService.pushNamed(
          AppRoutes.addExpense,
          args: {
            'friend': state.friendEntity,
            'origin': ExpenseOrigin.friend,
          },
        ),
        refreshType: RefreshType.friendDetail,
        id: state.friendEntity!.id,
        onRefresh: () {
          final currentFriend = context.read<FriendDetailBloc>().state.friendEntity;
          if (currentFriend != null) {
            context.read<FriendDetailBloc>().add(LoadFriendDetails(friend: currentFriend, hasChanges: true));
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataRefreshCubit, DataRefreshState>(
      listenWhen: (prev, curr) => curr.lastSignal?.type == RefreshType.friendDetail,
      listener: (context, state) {
        final friendId = context.read<FriendDetailBloc>().state.friendEntity?.id;
        if (context.read<DataRefreshCubit>().shouldRefresh(RefreshType.friendDetail, id: friendId)) {
          context.read<DataRefreshCubit>().clearRefresh(RefreshType.friendDetail, id: friendId);
          final currentFriend = context.read<FriendDetailBloc>().state.friendEntity;
          if (currentFriend != null) {
            context.read<FriendDetailBloc>().add(LoadFriendDetails(friend: currentFriend, hasChanges: true));
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
        useSafeArea: false,
        backgroundColor: Theme.of(context).ext.scaffoldBg,
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
              _FriendDetailAppBar(onBack: _onBack),
              SliverToBoxAdapter(
                child: BlocBuilder<FriendDetailBloc, FriendDetailState>(
                  builder: (context, state) {
                    if (state.friendEntity == null) return const SizedBox();
                    return _FriendDetailInfo(state.friendEntity!);
                  },
                ),
              ),
              BlocBuilder<FriendDetailBloc, FriendDetailState>(
                builder: (context, state) {
                  if (state.expenseStatus == FriendDetailExpenseStatus.loading) {
                    return const _ShimmerTransactionList();
                  }
                  if (state.expenseStatus == FriendDetailExpenseStatus.failure) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppErrorFullScreenWidget(
                        errorMessage: state.expenseErrorMessage,
                        onRefresh: () async {
                          final bloc = context.read<FriendDetailBloc>();
                          final currentFriend = bloc.state.friendEntity;
                          if (currentFriend != null) {
                            bloc.add(LoadFriendDetails(friend: currentFriend, hasChanges: true));
                          }
                          final nextState = await bloc.stream.firstWhere(
                            (s) => s.expenseStatus != FriendDetailExpenseStatus.loading,
                          );
                          return nextState.expenseStatus == FriendDetailExpenseStatus.success;
                        },
                      ),
                    );
                  }
                  if (state.expenseStatus == FriendDetailExpenseStatus.success && state.expenseHistory != null) {
                    return _TransactionList(expenses: state.expenseHistory?.expenses ?? []);
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
// Shimmer skeleton widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerTransactionItem extends StatelessWidget {
  const _ShimmerTransactionItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Bone.text(width: 110, fontSize: 14)),
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
      expandedHeight: 180.0,
      pinned: true,
      backgroundColor: Colors.transparent,
      leadingWidth: AppLayout.appBarLeadingWidth,
      leading: AppBackButton(
        onPressed: onBack,
        color: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.3),
      ),
      flexibleSpace: BlocBuilder<FriendDetailBloc, FriendDetailState>(
        builder: (context, state) {
          final friendEntity = state.friendEntity;
          
          return LayoutBuilder(
            builder: (context, constraints) {
              const double expandedHeight = 180.0;
              final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
              final double currentHeight = constraints.maxHeight;
              
              final double t = ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
              
              final double titleSizes = Tween<double>(begin: 18.0, end: 28.0).transform(t);
              final double titleLeft = Tween<double>(begin: 68.0, end: 20.0).transform(t);
              final double titleRight = Tween<double>(begin: 20.0, end: 20.0).transform(t);
              final double titleBottom = Tween<double>(begin: 16.0, end: 58.0).transform(t);
              final double memberOpacity = Tween<double>(begin: 0.0, end: 1.0).transform((t - 0.5).clamp(0.0, 0.5) * 2);

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (friendEntity?.imageUrl != null)
                    Hero(
                      tag: friendEntity!.id,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(friendEntity.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(color: AppColors.primaryTeal),
                  
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

                  Positioned(
                    left: titleLeft,
                    right: titleRight,
                    bottom: titleBottom,
                    child: Text(
                      friendEntity?.name ?? "",
                      style: GoogleFonts.outfit(
                        color: Theme.of(context).ext.surface,
                        fontSize: titleSizes,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (friendEntity != null)
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Opacity(
                        opacity: memberOpacity,
                        child: _buildBalancePill(friendEntity, state),
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

  Widget _buildBalancePill(FriendEntity friend, FriendDetailState state) {
    if (state.expenseStatus == FriendDetailExpenseStatus.loading) {
      return Skeletonizer(
        enabled: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                "Loading...",
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }
    final bool youAreOwed = state.expenseHistory?.status == 'you_are_owed';
    final double absOverall = friend.overallBalance.abs();
    final Color overallColor = friend.overallBalance == 0 ? Colors.white70 : (youAreOwed ? AppColors.successGreen : AppColors.errorRed);
    final formatter = NumberFormat('#,##0.##', 'en_IN');
    
    String prefix = friend.overallBalance == 0 ? "You and ${friend.name} are fully settled up" : (youAreOwed ? "${friend.name} owes you" : "You owe ${friend.name}");
    String amount = friend.overallBalance == 0 ? "" : " ₹${formatter.format(absOverall)}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: overallColor, size: 14),
          const SizedBox(width: 6),
          Text(
            "$prefix$amount",
            style: GoogleFonts.outfit(color: overallColor, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
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
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildActionButton(
              context: context,
              label: "Settle up",
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              onPressed: () {
                final state = context.read<FriendDetailBloc>().state;
                if (state.friendEntity != null) {
                  NavigationService.pushNamed(
                    AppRoutes.recordPayment,
                    args: {
                      'targetUserId': state.friendEntity!.id,
                      'targetUserName': state.friendEntity!.name,
                      'targetUserAvatar': state.friendEntity!.imageUrl,
                      'balance': state.friendEntity!.overallBalance,
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
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
          color: Theme.of(context).ext.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).ext.borderLight),
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
  final List<FriendExpenseEntity> expenses;

  const _TransactionList({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: AppEmptyState(
            icon: Icons.receipt_long_rounded,
            title: "No expenses yet",
            subtitle: "Add an expense with this friend to start splitting costs.",
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
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).ext.textPrimary,
              letterSpacing: 0.5,
            ),
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
      month = DateFormat('MMM').format(date).toUpperCase();
      day = DateFormat('d').format(date);
    } catch (_) {}

    final bool youAreOwed = expense.type == 'you_are_owed';
    final Color balanceColor = youAreOwed ? AppColors.successGreen : AppColors.errorRed; 
    final formatter = NumberFormat('#,##0.##', 'en_IN');

    final bool isSettlement = expense.description.toLowerCase().contains('settled up') || expense.description.toLowerCase().contains('settlement');
    
    final String balanceLabel = isSettlement 
        ? (youAreOwed ? 'You paid' : 'You received')
        : (youAreOwed ? 'Gets back' : 'Owes');
        
    final IconData iconData = isSettlement ? Icons.handshake_rounded : Icons.receipt_long_rounded;
    final Color iconColor = isSettlement ? AppColors.successGreen : AppColors.primaryTeal;
    final Color iconBgColor = isSettlement ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.primaryTeal.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: () {
        NavigationUtils.handleResult(
          context: context,
          navigation: NavigationService.pushNamed(AppRoutes.expanseDetail, args: {"expanse_id": expense.expenseId}),
          refreshType: RefreshType.friendDetail,
          id: context.read<FriendDetailBloc>().state.friendEntity?.id,
          onRefresh: () {
            final currentFriend = context.read<FriendDetailBloc>().state.friendEntity;
            if (currentFriend != null) {
              context.read<FriendDetailBloc>().add(LoadFriendDetails(friend: currentFriend, hasChanges: true));
            }
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).ext.surface,
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
                      Text(month, style: GoogleFonts.outfit(fontSize: 10, color: Theme.of(context).ext.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      Text(
                        day,
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).ext.textPrimary, height: 1.1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: expense.groupIcon != null ? Theme.of(context).ext.backgroundGrey : iconBgColor, 
                    shape: BoxShape.circle,
                    image: expense.groupIcon != null
                        ? DecorationImage(image: CachedNetworkImageProvider(expense.groupIcon!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: expense.groupIcon == null ? Icon(iconData, color: iconColor, size: 20) : null,
                ),
                const SizedBox(width: 12),
                // Description + group info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSettlement 
                            ? (youAreOwed ? 'You paid' : 'You received payment')
                            : expense.description,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).ext.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        expense.groupName != null ? 'In ${expense.groupName}' : "Non-group expense",
                        style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).ext.textSecondary, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Balance effect
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
        ),
      ),
    );
  }
}
