import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:split_ease/features/groups/presentation/pages/group_settings_page.dart';

import 'package:split_ease/features/groups/domain/entities/group_entity.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args["group_id"] != null) {
        context.read<GroupDetailBloc>().add(LoadGroupDetails(args["group_id"], previewGroup: args["preview_group"]));
      }
    });
    super.initState();
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
          _GroupDetailAppBar(onBack: _onBack),
          BlocBuilder<GroupDetailBloc, GroupDetailState>(
            builder: (context, state) {
              if (state.groupEntity == null) return const SliverToBoxAdapter(child: SizedBox());
              return _GroupDetailInfo(state.groupEntity!);
            },
          ),
          _TransactionList(),
        ],
      ),
      ),
    );
  }
}

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
                   context.read<GroupDetailBloc>().add(LoadGroupDetails(state.groupEntity!.id!, hasChanges: true));
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
              final double expandedHeight = 200.0;
              final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
              final double currentHeight = constraints.maxHeight;
              
              // t ranges from 0.0 (collapsed) to 1.0 (expanded)
              final double t = ((currentHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
              
              // Animations
              final double titleSizes = Tween<double>(begin: 20.0, end: 28.0).transform(t);
              final double titleLeft = Tween<double>(begin: 50.0, end: 20.0).transform(t); // 50 to clear back button roughly
              final double titleBottom = Tween<double>(begin: 14.0, end: 55.0).transform(t); // 14 centers in AppBar, 55 moves up for member pill
              final double memberOpacity = Tween<double>(begin: 0.0, end: 1.0).transform((t - 0.5).clamp(0.0, 0.5) * 2); // Fade in only in latter half

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
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
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return const _TransactionItem();
      }, childCount: 15),
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
