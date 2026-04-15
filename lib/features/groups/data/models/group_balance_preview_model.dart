import 'package:split_ease/features/groups/domain/entities/group_balance_preview_entity.dart';

class GroupBalancePreviewModel extends GroupBalancePreviewEntity {
  const GroupBalancePreviewModel({
    super.balance,
    super.fullName,
  });

  factory GroupBalancePreviewModel.fromJson(Map<String, dynamic> json) {
    // Handle balance casting safely whether it comes as int or double
    double? parsedBalance;
    if (json['balance'] != null) {
      if (json['balance'] is int) {
        parsedBalance = (json['balance'] as int).toDouble();
      } else if (json['balance'] is double) {
        parsedBalance = json['balance'] as double;
      }
    }

    return GroupBalancePreviewModel(
      balance: parsedBalance,
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['balance'] = super.balance;
    data['full_name'] = super.fullName;
    return data;
  }
}
