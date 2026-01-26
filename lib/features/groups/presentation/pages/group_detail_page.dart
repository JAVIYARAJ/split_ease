import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:split_ease/features/groups/presentation/pages/group_settings_page.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic argument = ModalRoute
          .of(context)
          ?.settings
          .arguments;
      if (argument != null && argument?["group_id"] != null) {
        context.read<GroupDetailBloc>().add(LoadGroupDetails(argument?["group_id"]));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      useSafeArea: false,
      backgroundColor: AppColors.backgroundWhite,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: Text(
          "Add expense",
          style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      child: CustomScrollView(
        slivers: [
          const _GroupDetailAppBar(),
          const _GroupDetailInfo(),
          _TransactionList(),
        ],
      ),
    );
  }
}

class _GroupDetailInfo extends StatelessWidget {


  const _GroupDetailInfo({super.key});

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
            const SizedBox(height: 32),
            Text(
              "January 2026",
              style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBlack),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


class _GroupDetailAppBar extends StatelessWidget {
  const _GroupDetailAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      backgroundColor: AppColors.primaryTeal,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => NavigationService.pop(),
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
                   context.read<GroupDetailBloc>().add(LoadGroupDetails(state.groupEntity!.id!));
                }
              });
            }
          },
        ),
      ],
      flexibleSpace: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          return FlexibleSpaceBar(
            background: Container(
              decoration: state.groupEntity?.groupIcon == null ? null : BoxDecoration(
                image: DecorationImage(image: CachedNetworkImageProvider(state.groupEntity!.groupIcon!),
                    fit: BoxFit.cover),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*Group name*/
                    Text(
                      state.groupEntity?.name ?? "",
                      style: GoogleFonts.openSans(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    /*Group member count*/
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withAlpha(30), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${state.groupEntity?.members?.length ?? 0} people",
                            style: GoogleFonts.openSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
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

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack),
            children: [
              const TextSpan(text: "You are owed "),
              TextSpan(
                text: "₹3,685.62",
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: AppColors.successGreen),
              ),
              const TextSpan(text: " overall"),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildBalanceLine("Kavan p.", "₹1,861.34", AppColors.successGreen),
        _buildBalanceLine("shira v.", "₹1,145.00", AppColors.successGreen),
        const SizedBox(height: 4),
        Text("Plus 3 more balances", style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildBalanceLine(String name, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.openSans(fontSize: 14, color: AppColors.textGrey),
          children: [
            TextSpan(text: "$name owes you "),
            TextSpan(
              text: amount,
              style: GoogleFonts.openSans(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Settle up", style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 8),
        _buildOutlineButton(Icons.diamond_outlined, "Charts"),
        const SizedBox(width: 8),
        _buildOutlineButton(null, "Balances"),
        const SizedBox(width: 8),
        _buildOutlineButton(null, "Totals"),
      ],
    );
  }

  Widget _buildOutlineButton(IconData? icon, String label) {
    return Expanded(
      flex: 2,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: const BorderSide(color: AppColors.borderGrey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: Colors.purple), const SizedBox(width: 4)],
            Text(
              // Changed Expanded to Text/Flexible to prevent layout overflow in small buttons
              label,
              style: GoogleFonts.openSans(color: AppColors.textBlack, fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return const _TransactionItem();
      }, childCount: 5),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Column(
            children: [
              Text("Jan", style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textGrey)),
              Text(
                "18",
                style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.backgroundLightGrey, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.receipt_long_outlined, color: AppColors.textGrey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Badam sake",
                  style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                ),
                Text("You paid ₹150.00", style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("you lent", style: GoogleFonts.openSans(fontSize: 12, color: AppColors.successGreen)),
              Text(
                "₹100.00",
                style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.successGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
