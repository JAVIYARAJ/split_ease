class FriendEntity {
  final String id;
  final String name;
  final String? imageUrl;
  final double balance; // Positive means they owe you, negative means you owe them
  final String activeGroup; // Context for the balance (e.g. "Trip to Vegas", "Non-group expenses")

  final String? email;
  final String? friendSince;
  final String? friendshipId;

  const FriendEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.balance,
    required this.activeGroup,
    this.email,
    this.friendSince,
    this.friendshipId,
  });
}
