import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/presentation/widgets/app_avatar.dart';
import 'package:split_ease/core/presentation/widgets/profile_picture_dialog.dart';
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
    final ext = Theme.of(context).ext;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ext.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ext.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ──
          GestureDetector(
            onTap: () {
              ProfilePictureDialog.show(
                context,
                avatarUrl: request.avatarUrl,
                name: request.fullName,
              );
            },
            onLongPress: () {
              ProfilePictureDialog.show(
                context,
                avatarUrl: request.avatarUrl,
                name: request.fullName,
              );
            },
            child: AppAvatar(
              url: request.avatarUrl,
              radius: 26,
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
                          color: ext.textPrimary,
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
                        color: ext.textSecondary,
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
                    color: ext.textSecondary,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Buttons ──
                Row(
                  children: [
                    // Confirm
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<FriendRequestsBloc>().add(
                                  RespondToRequest(
                                    friendshipId: request.friendshipId,
                                    action: 'accept',
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<FriendRequestsBloc>().add(
                                  RespondToRequest(
                                    friendshipId: request.friendshipId,
                                    action: 'reject',
                                  ),
                                );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: ext.inputFill,
                            foregroundColor: ext.textPrimary,
                            elevation: 0,
                            side: BorderSide(
                              color: ext.border.withValues(alpha: 0.3),
                            ),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ext.textPrimary,
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
}
