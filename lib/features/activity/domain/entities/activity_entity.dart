enum ActivityType {
  settlement, // "You added 'Settle all balances'"
  expense,    // "You added 'Aj tak amount'"
  payment,    // "You recorded a payment"
  modification, // "Meet K. deleted..."
  addToGroup, // "Meet K. added Kavan p."
}

class ActivityEntity {
  final String id;
  final ActivityType type;
  final String title; // E.g. "You added 'Settle all balances'"
  final String? subtitle; // E.g. "You get back ₹608.28"
  final double? amount;
  final bool isPositive; // For coloring (Green vs Orange)
  final DateTime timestamp;
  final String? imageUrl; // For group icon or user icon
  final String? activityId;

  const ActivityEntity({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.amount,
    required this.isPositive,
    required this.timestamp,
    this.imageUrl,
    this.activityId
  });
}
