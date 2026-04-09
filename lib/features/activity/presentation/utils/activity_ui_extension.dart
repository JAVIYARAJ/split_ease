import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import '../../domain/entities/activity_entity.dart';

extension ActivityUIPresentation on ActivityEntity {
  String getDisplayTitle(String? currentUserId, {String? currentUserName}) {
    final displayGroupName = groupName != null ? ' in "$groupName"' : '';
    final action = activityAction;
    
    // Check if the actor is the current user (by ID or Name fallback)
    bool isMe = false;
    if (actorId != null && currentUserId != null) {
      isMe = actorId == currentUserId;
    } else if (currentUserName != null) {
      isMe = actorName.toLowerCase() == currentUserName.toLowerCase();
    }
    
    final String subject = isMe ? "You" : actorName;

    if (action == ActivityType.added) {
      // Logic for joining/creating a group
      bool targetIsMe = false;
      if (referenceUserId != null && currentUserId != null) {
        targetIsMe = referenceUserId == currentUserId;
      } else if (referenceUserName != null && currentUserName != null) {
        targetIsMe = referenceUserName!.toLowerCase() == currentUserName.toLowerCase();
      } else if (referenceUserName == actorName) {
        targetIsMe = isMe;
      }

      if (isMe && targetIsMe) {
        return 'You created this group$displayGroupName';
      }
      
      final target = (referenceUserName == actorName) 
          ? (isMe ? "yourself" : "themselves") 
          : (referenceUserName ?? "someone");
      
      return '$subject added $target$displayGroupName';
    } else if (action == ActivityType.roleUpdated) {
      final newRole = metadata?['new_role'] ?? 'member';
      final target = referenceUserName ?? "someone";
      
      final bool targetIsMe = (referenceUserId != null && currentUserId != null && referenceUserId == currentUserId) ||
                              (referenceUserName != null && currentUserName != null && referenceUserName!.toLowerCase() == currentUserName.toLowerCase()) ||
                              (target == actorName && isMe);
                              
      final String possessiveTarget = targetIsMe ? "your" : (target == actorName ? "their" : "$target's");
      
      return '$subject updated $possessiveTarget role to $newRole$displayGroupName';
    } else if (action == ActivityType.expense || action == ActivityType.settlement) {
      final desc = description ?? metadata?['description'] ?? (action == ActivityType.expense ? 'an expense' : 'a settlement');
      return '$subject added "$desc"$displayGroupName';
    } else if (action == ActivityType.payment) {
      return '$subject recorded a payment$displayGroupName';
    } else {
      return '$subject performed an action$displayGroupName';
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
        return Icons.account_balance_wallet_rounded;
      case ActivityType.expense:
        return Icons.receipt_long_rounded;
      case ActivityType.payment:
        return Icons.payments_rounded;
      case ActivityType.added:
        return Icons.group_add_rounded;
      case ActivityType.roleUpdated:
        return Icons.security_rounded;
      default:
        return Icons.edit_note_rounded;
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
        return Colors.purple.shade500;
      case ActivityType.roleUpdated:
        return Colors.indigo.shade500;
      default:
        return Colors.blue.shade600;
    }
  }

  Color get iconBgColor {
    return iconColor.withValues(alpha: 0.1);
  }
}
