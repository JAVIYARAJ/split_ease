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
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Group Icon
                Hero(
                  tag: group.id ?? "group_${group.name}",
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade50,
                    ),
                    child: ClipOval(
                      child: group.groupIcon != null
                          ? AppImageView(
                              url: group.groupIcon,
                              height: 56,
                              width: 56,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primaryTeal, AppColors.primaryTealDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                _getIconData(group.groupType),
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name ?? "Unnamed Group",
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                       Row(
                        children: [
                          Icon(
                            _getIconData(group.groupType),
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            group.groupType?.isNotEmpty == true ? (group.groupType![0].toUpperCase() + group.groupType!.substring(1)) : "Group",
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Settlement Status (Placeholder for now)
                Container(
                   decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                   ),
                   padding: const EdgeInsets.all(8),
                   child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                ),
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
