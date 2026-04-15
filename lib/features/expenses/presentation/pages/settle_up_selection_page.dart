import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/routing/app_routes.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_balance_entity.dart';

class SettleUpSelectionPage extends StatelessWidget {
  const SettleUpSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final List<GroupMemberBalanceEntity> balances = args?['balances'] ?? [];
    final String? groupId = args?['groupId'];

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settle up",
          style: GoogleFonts.outfit(
            color: AppColors.textBlack,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "Who would you like to settle with?",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final balance = balances[index];
                final bool isOwed = balance.balance > 0;
                final Color color = isOwed ? AppColors.successGreen : AppColors.errorRed;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.borderGreyLight, width: 0.5),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Navigate to record payment
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
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            AppAvatar(
                              url: balance.avatar,
                              radius: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    balance.fullName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isOwed ? "owes you" : "you owe",
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "₹${NumberFormat('#,##0.##', 'en_IN').format(balance.balance.abs())}",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.iconGrey),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: balances.length,
            ),
          ),
          if (balances.isEmpty)
             SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.successGreen),
                      const SizedBox(height: 16),
                      Text(
                        "All settled up!",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
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
}
