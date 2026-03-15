import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.type,
    required super.title,
    super.subtitle,
    super.amount,
    required super.isPositive,
    required super.timestamp,
    super.imageUrl,
    super.activityId
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String?;
    final actorName = json['actor_name'] as String? ?? 'Someone';
    final groupName = json['group_name'] as String?;
    final description = json['description'] as String?;
    final amountType = json['amount_type'] as String?;

    // Parse balance effect safely handling int/double
    double? balanceEffect;
    if (json['balance_effect'] != null) {
      if (json['balance_effect'] is num) {
        balanceEffect = (json['balance_effect'] as num).toDouble();
      } else if (json['balance_effect'] is String) {
        balanceEffect = double.tryParse(json['balance_effect']);
      }
    }

    ActivityType type;
    String title = '';
    String? subtitle;
    bool isPositive = false;

    final displayGroupName = groupName ?? 'Non-group';

    if (rawType == 'group_member_added') {
      type = ActivityType.addToGroup;
      title = '$actorName added a new member in $displayGroupName';
      isPositive = true;
    } else if (rawType == 'expense') {
      type = ActivityType.expense;
      title = '$actorName added "${description ?? 'an expense'}" in $displayGroupName';
      
      if (amountType == 'you_are_owed') {
        final amountStr = balanceEffect?.toStringAsFixed(2) ?? '0.00';
        subtitle = 'You get back ₹$amountStr';
        isPositive = true;
      } else if (amountType == 'you_owe') {
        final amountStr = balanceEffect?.abs().toStringAsFixed(2) ?? '0.00';
        subtitle = 'You owe ₹$amountStr';
        isPositive = false;
      } else {
        subtitle = balanceEffect != null ? '₹${balanceEffect.abs().toStringAsFixed(2)}' : null;
        isPositive = balanceEffect != null && balanceEffect >= 0;
      }
    } else if (rawType == 'settlement') {
      type = ActivityType.settlement;
      title = '$actorName added "Settle all balances" in $displayGroupName';
      isPositive = true;
    } else if (rawType == 'payment') {
      type = ActivityType.payment;
      title = '$actorName recorded a payment in $displayGroupName';
      isPositive = true;
    } else {
      type = ActivityType.modification;
      title = '$actorName performed an action in $displayGroupName';
    }

    return ActivityModel(
      id: json['activity_id'] as String? ?? '',
      type: type,
      title: title,
      subtitle: subtitle,
      amount: balanceEffect?.abs(),
      isPositive: isPositive,
      timestamp: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'])?.toLocal() ?? DateTime.now() 
          : DateTime.now(),
      activityId: json["activity_id"]
    );
  }
}
