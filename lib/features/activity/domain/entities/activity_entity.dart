enum ActivityType {
  settlement,
  expense,
  payment,
  modification,
  added,
  roleUpdated,
  unknown,
}

class ActivityEntity {
  final String activityId;
  final String? actorId; // ID of the person who performed the action
  final String type; // Raw type string
  final String actorName;
  final String? groupName;
  final String? description;
  final String? amountType;
  final double? balanceEffect;
  final Map<String, dynamic>? metadata;
  final String? referenceUserName;
  final String? referenceUserId;
  final DateTime createdAt;
  final bool isUnread;

  const ActivityEntity({
    required this.activityId,
    this.actorId,
    required this.type,
    required this.actorName,
    this.groupName,
    this.description,
    this.amountType,
    this.balanceEffect,
    this.metadata,
    this.referenceUserName,
    this.referenceUserId,
    required this.createdAt,
    this.isUnread = false,
  });

  ActivityType get activityAction {
    switch (type) {
      case 'settlement':
        return ActivityType.settlement;
      case 'expense':
        return ActivityType.expense;
      case 'payment':
        return ActivityType.payment;
      case 'added':
        return ActivityType.added;
      case 'role_updated':
        return ActivityType.roleUpdated;
      default:
        return ActivityType.unknown;
    }
  }
}
