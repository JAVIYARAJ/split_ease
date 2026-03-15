import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/expenses/presentation/bloc/payer/payer_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

import '../../../../injection_container.dart';

class PayerSelectionPage extends StatelessWidget {
  const PayerSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final members = args['members'] as List<GroupMemberEntity>;
    final currentPayerId = args['currentPayerId'] as String?;

    return BlocProvider(
      create: (context) => sl<PayerBloc>()..add(LoadPayerEvent(members: members, initialPayerId: currentPayerId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.openSans(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          leadingWidth: 80,
          title: Text(
            "Choose payer",
            style: GoogleFonts.openSans(
              color: AppColors.textBlack,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<PayerBloc, PayerState>(
          builder: (context, state) {
            final members = state.members;
            final selectedUserId = state.selectedPayerId ?? (members.isNotEmpty ? members.first.userId : '');

            return ListView.builder(
              itemCount: members.length + 1, // +1 for "Multiple people"
              itemBuilder: (context, index) {
                if (index == members.length) {
                  return _buildMultiplePeopleOption(context);
                }
                final member = members[index];
                final isSelected = member.userId == selectedUserId;
                return InkWell(
                  onTap: () {
                    if (member.userId != null) {
                      context.read<PayerBloc>().add(SelectPayerEvent(member.userId!));
                      Navigator.pop(context, member.userId); // Return result
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: member.avtar != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(member.avtar!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: member.avtar == null ? AppColors.primaryTeal : null,
                          ),
                          child: member.avtar == null
                              ? Center(
                                  child: Text(
                                    member.fullName?.substring(0, 1).toUpperCase() ?? "?",
                                    style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            member.fullName ?? "Unknown",
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: AppColors.textBlack,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, color: AppColors.primaryTeal),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMultiplePeopleOption(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Implement multiple payers logic if needed
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Text(
              "Multiple people",
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: AppColors.textBlack,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.iconGrey),
          ],
        ),
      ),
    );
  }
}
