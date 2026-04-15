import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import '../../domain/entities/activity_entity.dart';

extension ActivityUIPresentation on ActivityEntity {
  String getDisplayTitle(String? currentUserId, {String? currentUserName}) {
    final groupSuffix = groupName != null ? ' in "$groupName"' : 'in Non group expense';
    final action = activityAction;
    
    bool isMe = false;
    if (actorId != null && currentUserId != null) {
      isMe = actorId == currentUserId;
    } else if (currentUserName != null) {
      isMe = actorName.toLowerCase() == currentUserName.toLowerCase();
    }
    
    final String subject = isMe ? "You" : actorName;

    switch (action) {
      case ActivityType.added:
        bool targetIsMe = (referenceUserId != null && currentUserId != null && referenceUserId == currentUserId) ||
                          (referenceUserName != null && currentUserName != null && referenceUserName!.toLowerCase() == currentUserName.toLowerCase()) ||
                          (referenceUserName == actorName && isMe);

        if (targetIsMe) {
          return isMe ? 'You joined the group$groupSuffix' : '$actorName joined the group$groupSuffix';
        }
        
        final target = (referenceUserName == actorName) 
            ? (isMe ? "yourself" : "themselves") 
            : (referenceUserName ?? "someone");
        
        return '$subject added $target to "$groupName"';

      case ActivityType.removed:
        bool targetIsMe = (referenceUserId != null && currentUserId != null && referenceUserId == currentUserId) ||
                          (referenceUserName != null && currentUserName != null && referenceUserName!.toLowerCase() == currentUserName.toLowerCase());

        if (targetIsMe) {
          return isMe ? 'You left the group$groupSuffix' : 'You were removed from the group$groupSuffix';
        }
        
        final target = referenceUserName ?? "someone";
        return '$subject removed $target from "$groupName"';

      case ActivityType.roleUpdated:
        final newRole = metadata?['new_role'] ?? 'member';
        final target = referenceUserName ?? "someone";
        
        final bool targetIsMe = (referenceUserId != null && currentUserId != null && referenceUserId == currentUserId) ||
                                (referenceUserName != null && currentUserName != null && referenceUserName!.toLowerCase() == currentUserName.toLowerCase()) ||
                                (target == actorName && isMe);
                                
        final String possessiveTarget = targetIsMe ? "your" : (target == actorName ? "their" : "$target's");
        return '$subject updated $possessiveTarget role to $newRole$groupSuffix';

      case ActivityType.expense:
        final desc = description ?? metadata?['description'] ?? 'an expense';
        return '$subject added "$desc"$groupSuffix';

      case ActivityType.settlement:
        final desc = description ?? metadata?['description'] ?? 'a settlement';
        return '$subject recorded a settlement$groupSuffix';

      case ActivityType.payment:
        return '$subject recorded a payment$groupSuffix';

      case ActivityType.modification:
        final entityName = type == 'expense' ? 'expense' : (type == 'settlement' ? 'settlement' : 'activity');
        final desc = description ?? metadata?['description'];
        if (desc != null) {
          return '$subject updated "$desc"$groupSuffix';
        }
        return '$subject updated an $entityName$groupSuffix';

      case ActivityType.deleted:
        final entityName = type == 'expense' ? 'expense' : (type == 'settlement' ? 'settlement' : 'activity');
        final desc = description ?? metadata?['description'];
        if (desc != null) {
          return '$subject deleted "$desc"$groupSuffix';
        }
        return '$subject deleted an $entityName$groupSuffix';

      case ActivityType.restored:
        final entityName = type == 'expense' ? 'expense' : (type == 'settlement' ? 'settlement' : 'activity');
        final desc = description ?? metadata?['description'];
        if (desc != null) {
          return '$subject restored "$desc"$groupSuffix';
        }
        return '$subject restored an $entityName$groupSuffix';

      case ActivityType.unknown:
      default:
        return '$subject performed an action$groupSuffix';
    }
  }

  String? get displaySubtitle {
    if (amountType == 'you_are_owed') {
      final amountStr = balanceEffect?.toStringAsFixed(2) ?? '0.00';
      return 'You get back ₹$amountStr';
    } else if (amountType == 'you_owe') {
      final amountStr = balanceEffect?.abs().toStringAsFixed(2) ?? '0.00';
      return 'You owe ₹$amountStr';
    } else if (balanceEffect != null && balanceEffect != 0) {
      return '₹${balanceEffect!.abs().toStringAsFixed(2)}';
    }
    return null;
  }

  bool get isPositiveEffect {
    if (amountType == 'you_are_owed') return true;
    if (amountType == 'you_owe') return false;
    if (balanceEffect != null) return balanceEffect! >= 0;
    return true; 
  }

  IconData get iconData {
    switch (activityAction) {
      case ActivityType.settlement:
        return Icons.handshake_rounded;
      case ActivityType.expense:
        return Icons.receipt_long_rounded;
      case ActivityType.payment:
        return Icons.payments_rounded;
      case ActivityType.added:
        return Icons.person_add_alt_1_rounded;
      case ActivityType.removed:
        return Icons.person_remove_alt_1_rounded;
      case ActivityType.deleted:
        return Icons.delete_sweep_rounded;
      case ActivityType.restored:
        return Icons.settings_backup_restore_rounded;
      case ActivityType.roleUpdated:
        return Icons.admin_panel_settings_rounded;
      case ActivityType.modification:
        return Icons.edit_note_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color get iconColor {
    switch (activityAction) {
      case ActivityType.settlement:
        return AppColors.primary;
      case ActivityType.expense:
        return AppColors.warningOrange;
      case ActivityType.payment:
        return AppColors.successGreen;
      case ActivityType.added:
        return Colors.blue.shade600;
      case ActivityType.removed:
      case ActivityType.deleted:
        return AppColors.errorRed;
      case ActivityType.restored:
        return const Color(0xFF00897B); // Teal 600
      case ActivityType.roleUpdated:
        return Colors.indigo.shade600;
      case ActivityType.modification:
        return Colors.amber.shade700;
      default:
        return AppColors.textGrey;
    }
  }

  Color get iconBgColor {
    return iconColor.withValues(alpha: 0.08);
  }
}
