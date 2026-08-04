part of 'settle_up_cubit.dart';


class SettleUpState extends Equatable {
  final String? currentUserId;
  final String? targetUserId;
  final String? groupId;
  final String amount;
  final double targetBalance; // The original balance fetched from arguments
  final String note;
  final DateTime date;
  final SettleUpStatus status;
  final String? errorMessage;
  final List<GroupEntity> commonGroups;
  final List<ExpensePaymentMethodEntity> paymentMethods;
  final String? selectedPaymentMethodId;

  SettleUpState({
    this.currentUserId,
    this.targetUserId,
    this.groupId,
    this.amount = '0',
    this.targetBalance = 0,
    this.note = '',
    DateTime? date,
    this.status = SettleUpStatus.initial,
    this.errorMessage,
    this.commonGroups = const [],
    this.paymentMethods = const [],
    this.selectedPaymentMethodId,
  }) : date = date ?? DateTime.now();

  /// True if the entered amount is greater than the actual balance
  bool get isOverpayment {
    final double? amt = double.tryParse(amount);
    if (amt == null) return false;
    return amt > targetBalance.abs() + 0.01;
  }

  /// How much extra is being paid beyond the actual balance
  double get overpaymentAmount {
    final double? amt = double.tryParse(amount);
    if (amt == null) return 0;
    final extra = amt - targetBalance.abs();
    return extra > 0 ? extra : 0;
  }

  /// The actual settlement portion (capped at balance, remainder is advance)
  double get settlementAmount {
    final double? amt = double.tryParse(amount);
    if (amt == null) return 0;
    return amt > targetBalance.abs() ? targetBalance.abs() : amt;
  }

  SettleUpState copyWith({
    String? currentUserId,
    String? targetUserId,
    String? groupId,
    String? amount,
    double? targetBalance,
    String? note,
    DateTime? date,
    SettleUpStatus? status,
    String? errorMessage,
    List<GroupEntity>? commonGroups,
    List<ExpensePaymentMethodEntity>? paymentMethods,
    String? selectedPaymentMethodId,
    bool? clearGroupId,
  }) {
    return SettleUpState(
      currentUserId: currentUserId ?? this.currentUserId,
      targetUserId: targetUserId ?? this.targetUserId,
      groupId: clearGroupId == true ? null : (groupId ?? this.groupId),
      amount: amount ?? this.amount,
      targetBalance: targetBalance ?? this.targetBalance,
      note: note ?? this.note,
      date: date ?? this.date,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      commonGroups: commonGroups ?? this.commonGroups,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethodId: selectedPaymentMethodId ?? this.selectedPaymentMethodId,
    );
  }

  @override
  List<Object?> get props => [
        currentUserId,
        targetUserId,
        groupId,
        amount,
        targetBalance,
        note,
        date,
        status,
        errorMessage,
        commonGroups,
        paymentMethods,
        selectedPaymentMethodId,
      ];
}
