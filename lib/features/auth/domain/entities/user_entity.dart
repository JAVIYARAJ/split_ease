/*Main user blue print for the app*/
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? role;
  final String? lastExpenseCategoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.role,
    this.lastExpenseCategoryId,
    this.createdAt,
    this.updatedAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? role,
    String? lastExpenseCategoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      lastExpenseCategoryId: lastExpenseCategoryId ?? this.lastExpenseCategoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
