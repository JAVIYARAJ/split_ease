import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/presentation/widgets/base_screen.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/utils/app_alerts.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_requests_bloc.dart';
import 'package:split_ease/features/friends/presentation/widgets/friend_request_tile.dart';
import 'package:split_ease/injection_container.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  bool _hasResponded = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FriendRequestsBloc>()..add(LoadFriendRequests()),
      child: BlocConsumer<FriendRequestsBloc, FriendRequestsState>(
        listener: (context, state) {
          if (state.respondStatus == RespondStatus.success) {
            _hasResponded = true;
            AppAlerts.showSuccess(context, state.respondMessage);
          } else if (state.respondStatus == RespondStatus.failure) {
            AppAlerts.showError(context, state.respondMessage);
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                Navigator.pop(context, _hasResponded);
              }
            },
            child: BaseScreen(
              appBar: AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: false,
                iconTheme: const IconThemeData(color: AppColors.textBlack),
                title: Text(
                  'Friend Requests',
                  style: GoogleFonts.outfit(
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              child: _buildBody(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(FriendRequestsState state) {
    if (state.status == FriendRequestsStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == FriendRequestsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            state.errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }

    if (state.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending requests',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "You're all caught up!",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.iconGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: state.requests.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return FriendRequestTile(request: state.requests[index]);
      },
    );
  }
}
