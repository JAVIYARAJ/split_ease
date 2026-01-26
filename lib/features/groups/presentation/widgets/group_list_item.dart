import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/features/groups/domain/entities/group_type.dart';
import '../../../../../core/presentation/widgets/app_image_view.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/group_entity.dart';

class GroupListItem extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback? onTap;

  const GroupListItem({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Group Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: group.groupIcon != null
                      ? AppImageView(
                          url: group.groupIcon,
                          height: 50,
                          width: 50,
                          radius: 12,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryTeal,
                                AppColors.primaryTealDark
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(_getIconData(group.groupType),
                              color: Colors.white, size: 24),
                        ),
                ),
                const SizedBox(width: 16),

                // Name
                Expanded(
                  child: Text(
                    group.name ?? "Unnamed Group",
                    style: GoogleFonts.openSans(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Forward Icon
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textBlack.withAlpha(155)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String? type) {
    if (type == GroupType.home.name) {
      return Icons.home_rounded;
    } else if (type == GroupType.couple.name) {
      return Icons.favorite_rounded;
    } else if (type == GroupType.trip.name) {
      return Icons.flight_takeoff_rounded;
    } else {
      return Icons.list_alt_rounded;
    }
  }
}
