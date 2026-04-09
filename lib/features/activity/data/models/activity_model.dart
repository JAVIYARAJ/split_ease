import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.activityId,
    super.actorId,
    required super.type,
    required super.actorName,
    super.groupName,
    super.description,
    super.amountType,
    super.balanceEffect,
    super.metadata,
    super.referenceUserName,
    super.referenceUserId,
    required super.createdAt,
    super.isUnread,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ActivityModel(
      activityId: json['activity_id'] as String? ?? json['id'] as String? ?? '',
      actorId: json['user_id'] as String? ?? json['actor_id'] as String?,
      type: json['type'] as String? ?? '',
      actorName: json['actor_name'] as String? ?? 'Someone',
      groupName: json['group_name'] as String?,
      description: json['description'] as String?,
      amountType: json['amount_type'] as String?,
      balanceEffect: parseDouble(json['balance_effect']),
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] as Map<String, dynamic> : null,
      referenceUserName: json['reference_user_name'] as String?,
      referenceUserId: json['reference_user_id'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'])?.toLocal() ?? DateTime.now() 
          : DateTime.now(),
      isUnread: json['is_unread'] as bool? ?? false,
    );
  }
}
