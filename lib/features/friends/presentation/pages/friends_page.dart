import 'package:flutter/material.dart';
import 'package:split_ease/core/presentation/widgets/custom_refresh_indicator.dart';
import 'package:split_ease/core/presentation/widgets/success_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import '../../../../../core/presentation/widgets/base_screen.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:split_ease/features/groups/presentation/pages/qr_scanner_page.dart';
import 'friend_requests_page.dart';

import '../widgets/friend_list_item.dart';
import '../bloc/friends_bloc.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FriendsBloc>().add(LoadFriends());
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const SizedBox(),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 28),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendRequestsPage()));
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "Requests",
                      style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScannerPage()));
              if (result != null && result is String && context.mounted) {
                context.read<FriendsBloc>().add(FriendQrJoinEvent(friendId: result));
              }
            },
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), // Raise FAB above custom bottom nav
        child: FloatingActionButton.extended(
          heroTag: "friends_fab",
          onPressed: () {},
          backgroundColor: const Color(0xFF00A99D),
          // Teal/Green shade from image
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: Text(
            "Add expense",
            style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: BlocListener<FriendsBloc, FriendsState>(
        listener: (context, state) {
          if (state.joinStatus == FriendJoinStatus.success) {
            showDialog(
              context: context,
              builder: (context) =>
                  SuccessDialog(description: "Friend request sent successfully", buttonText: "Okay", onContinue: () => Navigator.pop(context)),
            );
          } else if (state.joinStatus == FriendJoinStatus.failure) {
            AppAlerts.showError(context, state.joinErrorMessage);
          }
        },
        child: Column(
          children: [
            // Overall Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Overall, you owe ',
                      style: GoogleFonts.openSans(fontSize: 18, color: AppColors.textBlack, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: '₹0',
                          style: GoogleFonts.openSans(fontSize: 18, color: AppColors.warningOrange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: Colors.black), // Filter icon
                  ),
                ],
              ),
            ),

            // Friends List
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (context, state) {
                  if (state.status == FriendsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == FriendsStatus.success) {
                    if (state.friends.isEmpty) {
                      return const Center(child: Text("No friends found"));
                    }
                    return CustomRefreshIndicator(
                      onRefresh: () async {
                        context.read<FriendsBloc>().add(LoadFriends());
                      },
                      child: ListView.separated(
                        itemCount: state.friends.length,
                        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1, indent: 80, endIndent: 24),
                        itemBuilder: (context, index) {
                          final friend = state.friends[index];
                          return FriendListItem(
                            friend: friend,
                            onTap: () {
                              // Navigate to friend details
                            },
                          );
                        },
                        padding: const EdgeInsets.only(bottom: 100), // Add padding for FAB + Nav Bar
                      ),
                    );
                  } else if (state.status == FriendsStatus.failure) {
                    return Center(child: Text(state.errorMessage));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
