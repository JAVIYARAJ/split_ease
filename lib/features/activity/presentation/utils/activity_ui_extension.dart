import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import '../../domain/entities/activity_entity.dart';

extension ActivityUIPresentation on ActivityEntity {
  String getDisplayTitle(String? currentUserId, {String? currentUserName}) {
    final action = activityAction;
    
    bool isMe = false;
    if (actorId != null && currentUserId != null) {
      isMe = actorId == currentUserId;
    } else if (currentUserName != null) {
      isMe = actorName.toLowerCase() == currentUserName.toLowerCase();
    }
    
    final String subject = isMe ? "You" : actorName;
    final String groupInfo = groupName != null ? ' in "$groupName"' : '';
    final String toGroup = groupName != null ? ' to "$groupName"' : '';
    final String fromGroup = groupName != null ? ' from "$groupName"' : '';

    switch (action) {
      case ActivityType.added:
        bool isSelfJoin = (referenceUserId != null && actorId != null && referenceUserId == actorId) ||
                          (referenceUserName == actorName);

        bool targetIsMe = (referenceUserId != null && currentUserId != null && referenceUserId == currentUserId) ||
                          (referenceUserName != null && currentUserName != null && referenceUserName!.toLowerCase() == currentUserName.toLowerCase());

        if (isSelfJoin) {
          return isMe ? 'You joined "$groupName"' : '$actorName joined "$groupName"';
        }

        if (targetIsMe) {
          return '$actorName added you$toGroup';
        }
        
        final target = referenceUserName ?? "someone";
        return '$subject added $target$toGroup';

      case ActivityType.removed:
        bool targetIsMe = (referenceUserId != null && currentUserId != null && referenceUserId == currentUserId) ||
                          (referenceUserName != null && currentUserName != null && referenceUserName!.toLowerCase() == currentUserName.toLowerCase());

        bool isSelfRemoval = (referenceUserId != null && actorId != null && referenceUserId == actorId) ||
                             (referenceUserName == actorName);

        if (targetIsMe) {
          return isMe ? 'You left "$groupName"' : 'You were removed$fromGroup by $actorName';
        }
        
        if (isSelfRemoval) {
          return '$subject left "$groupName"';
        }
        
        final target = referenceUserName ?? "someone";
        return '$subject removed $target$fromGroup';

      case ActivityType.roleUpdated:
        final newRoleRaw = metadata?['new_role']?.toString() ?? 'member';
        final oldRoleRaw = metadata?['old_role']?.toString();
        
        final newRole = newRoleRaw.isNotEmpty ? '${newRoleRaw[0].toUpperCase()}${newRoleRaw.substring(1)}' : newRoleRaw;
        final oldRole = oldRoleRaw != null && oldRoleRaw.isNotEmpty ? '${oldRoleRaw[0].toUpperCase()}${oldRoleRaw.substring(1)}' : null;
        
        final target = referenceUserName ?? "someone";
        
        final bool targetIsMe = (referenceUserId != null && currentUserId != null && referenceUserId == currentUserId) ||
                                (referenceUserName != null && currentUserName != null && referenceUserName!.toLowerCase() == currentUserName.toLowerCase()) ||
                                (target == actorName && isMe);
                                
        final String possessiveTarget = targetIsMe ? "your" : (target == actorName ? "their" : "$target's");
        
        if (oldRole != null) {
          return '$subject changed $possessiveTarget role from $oldRole to $newRole$groupInfo';
        }
        return '$subject updated $possessiveTarget role to $newRole$groupInfo';

      case ActivityType.expense:
        final desc = description ?? metadata?['description'] ?? 'an expense';
        final amount = metadata?['amount'];
        if (amount != null) {
          final amountStr = amount is num 
              ? (amount.truncateToDouble() == amount ? amount.toInt().toString() : amount.toStringAsFixed(2))
              : amount.toString();
          return '$subject added "$desc" for ₹$amountStr$toGroup';
        }
        return '$subject added "$desc"$toGroup';

      case ActivityType.settlement:
        return '$subject recorded a settlement$groupInfo';

      case ActivityType.payment:
        return '$subject recorded a payment$groupInfo';

      case ActivityType.modification:
        final desc = description ?? metadata?['description'];
        if (desc != null) {
          return '$subject updated "$desc"$groupInfo';
        }
        final entityName = type == 'expense' ? 'expense' : (type == 'settlement' ? 'settlement' : 'activity');
        return '$subject updated an $entityName$groupInfo';

      case ActivityType.deleted:
        final desc = description ?? metadata?['description'];
        if (desc != null) {
          return '$subject deleted "$desc"$fromGroup';
        }
        final entityName = type == 'expense' ? 'expense' : (type == 'settlement' ? 'settlement' : 'activity');
        return '$subject deleted an $entityName$fromGroup';

      case ActivityType.restored:
        final desc = description ?? metadata?['description'];
        if (desc != null) {
          return '$subject restored "$desc"$toGroup';
        }
        final entityName = type == 'expense' ? 'expense' : (type == 'settlement' ? 'settlement' : 'activity');
        return '$subject restored an $entityName$toGroup';

      case ActivityType.groupCreated:
        return '$subject created the group "$groupName"';

      case ActivityType.limitExceeded:
        if (description != null && description!.isNotEmpty) {
          return description!;
        }
        return 'Category limit exceeded';

      case ActivityType.unknown:
      default:
        return '$subject performed an action$groupInfo';
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
      case ActivityType.groupCreated:
        return Icons.group_add_rounded;
      case ActivityType.limitExceeded:
        return Icons.warning_amber_rounded;
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
      case ActivityType.groupCreated:
        return AppColors.primary;
      case ActivityType.limitExceeded:
        return AppColors.errorRed;
      default:
        return AppColors.textGrey;
    }
  }

  Color get iconBgColor {
    return iconColor.withValues(alpha: 0.08);
  }
}
