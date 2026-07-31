import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
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
        backgroundColor: Theme.of(context).ext.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Theme.of(context).ext.scaffoldBg,
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
              color: Theme.of(context).ext.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<PayerBloc, PayerState>(
          builder: (context, state) {
            final members = state.members;
            final selectedUserId = state.effectiveSelectedId;

            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
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
                        AppAvatar(
                          url: member.avtar,
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            member.fullName ?? "Unknown",
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: Theme.of(context).ext.textPrimary,
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

}
