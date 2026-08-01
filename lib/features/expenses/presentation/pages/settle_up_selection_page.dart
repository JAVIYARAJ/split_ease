import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/app_back_button.dart';
import 'package:split_ease/core/theme/app_layout.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_balance_entity.dart';

class SettleUpSelectionPage extends StatelessWidget {
  const SettleUpSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final List<GroupMemberBalanceEntity> balances = args?['balances'] ?? [];
    final String? groupId = args?['groupId'];

    return Scaffold(
      backgroundColor: Theme.of(context).ext.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).ext.backgroundGrey,
        elevation: 0,
        leadingWidth: AppLayout.appBarLeadingWidth,
        leading: AppBackButton(
          onPressed: () => Navigator.pop(context),
          color: Theme.of(context).ext.textPrimary,
          backgroundColor: Theme.of(context).ext.scaffoldBg,
        ),
        title: Text(
          "Settle up",
          style: GoogleFonts.outfit(
            color: Theme.of(context).ext.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 12.0,
                bottom: 8.0,
              ),
              child: Text(
                "Select a member to settle with",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).ext.textSecondary,
                ),
              ),
            ),
          ),
          if (balances.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).ext.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).ext.borderLight,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < balances.length; i++) ...[
                        _buildBalanceItem(context, balances[i], groupId),
                        if (i < balances.length - 1)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Theme.of(context).ext.borderLight,
                            indent: 64,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          if (balances.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 64,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "All settled up!",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).ext.textSecondary,
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

  Widget _buildBalanceItem(
    BuildContext context,
    GroupMemberBalanceEntity balance,
    String? groupId,
  ) {
    final bool isOwed = balance.balance > 0;
    final Color color = isOwed ? AppColors.successGreen : AppColors.errorRed;

    return InkWell(
      onTap: () {
        NavigationService.pushNamed(
          AppRoutes.recordPayment,
          args: {
            'targetUserId': balance.userId,
            'targetUserName': balance.fullName,
            'targetUserAvatar': balance.avatar,
            'balance': balance.balance,
            'groupId': groupId,
          },
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            AppAvatar(url: balance.avatar, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balance.fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).ext.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOwed ? "owes you" : "you owe",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Theme.of(context).ext.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "₹${NumberFormat('#,##0.##', 'en_IN').format(balance.balance.abs())}",
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Theme.of(context).ext.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
