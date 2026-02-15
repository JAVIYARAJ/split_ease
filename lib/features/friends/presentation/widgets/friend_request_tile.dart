import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/features/friends/domain/entities/friend_request_entity.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_requests_bloc.dart';

class FriendRequestTile extends StatelessWidget {
  final FriendRequestEntity request;

  const FriendRequestTile({super.key, required this.request});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ──
          GestureDetector(
            onLongPress: () => _showFullImage(context),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: request.avatarUrl != null
                  ? NetworkImage(request.avatarUrl!)
                  : null,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: request.avatarUrl == null
                  ? Text(
                      request.fullName[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // ── Content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Name + Time ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.fullName,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(request.requestedAt),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                // ── Subtitle ──
                Text(
                  'Wants to connect with you',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C182A),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Buttons ──
                Row(
                  children: [
                    // Confirm
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextButton(
                          onPressed: () {
                            context.read<FriendRequestsBloc>().add(
                                  RespondToRequest(
                                    friendshipId: request.friendshipId,
                                    action: 'accept',
                                  ),
                                );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Delete
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextButton(
                          onPressed: () {
                            context.read<FriendRequestsBloc>().add(
                                  RespondToRequest(
                                    friendshipId: request.friendshipId,
                                    action: 'reject',
                                  ),
                                );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF2F2F2),
                            foregroundColor: const Color(0xFF333333),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    if (request.avatarUrl == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: Image.network(
                request.avatarUrl!,
                width: 280,
                height: 280,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: 280,
                    height: 280,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stack) {
                  return Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      request.fullName[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
