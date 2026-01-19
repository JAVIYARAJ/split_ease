class GroupBalanceDetail {
  final String memberName;
  final double amount;
  final bool isOwedToUser; // true if they owe you, false if you owe them

  const GroupBalanceDetail({
    required this.memberName,
    required this.amount,
    required this.isOwedToUser,
  });
}
