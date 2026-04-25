enum ActivityType {
  settlement,
  expense,
  payment,
  modification,
  added,
  removed,
  deleted,
  restored,
  roleUpdated,
  groupCreated,
  unknown,
}

class ActivityEntity {
  final String activityId;
  final String? actorId; 
  final String type; // entity_type (e.g. expense, group_member)
  final String? action; // action performed (e.g. created, updated, removed)
  final String actorName;
  final String? groupName;
  final String? description;
  final String? amountType;
  final double? balanceEffect;
  final Map<String, dynamic>? metadata;
  final String? referenceUserName;
  final String? referenceUserId;
  final String? entityId;
  final String? expenseId;
  final String? groupId;
  final DateTime createdAt;
  final bool isUnread;

  const ActivityEntity({
    required this.activityId,
    this.actorId,
    required this.type,
    this.action,
    required this.actorName,
    this.groupName,
    this.description,
    this.amountType,
    this.balanceEffect,
    this.metadata,
    this.referenceUserName,
    this.referenceUserId,
    this.entityId,
    this.expenseId,
    this.groupId,
    required this.createdAt,
    this.isUnread = false,
  });

  ActivityType get activityAction {
    if (type == 'settlement' || (type == 'expense' && description?.toLowerCase() == 'settlement')) {
      return ActivityType.settlement;
    }
    
    switch (action) {
      case 'created':
        if (type == 'expense') return ActivityType.expense;
        if (type == 'group_member') return ActivityType.added;
        break;
      case 'updated':
        return ActivityType.modification;
      case 'deleted':
        if (type == 'expense' || type == 'settlement') return ActivityType.deleted;
        return ActivityType.removed;
      case 'restored':
        return ActivityType.restored;
      case 'removed':
        return ActivityType.removed;
      case 'added':
        return ActivityType.added;
      case 'role_updated':
        return ActivityType.roleUpdated;
      case 'group_created':
        return ActivityType.groupCreated;
    }

    switch (type) {
      case 'added':
        return ActivityType.added;
      case 'removed':
        return ActivityType.removed;
      case 'restored':
        return ActivityType.restored;
      case 'role_updated':
        return ActivityType.roleUpdated;
      case 'payment':
        return ActivityType.payment;
      case 'expense':
        return ActivityType.expense;
      default:
        return ActivityType.unknown;
    }
  }
}
