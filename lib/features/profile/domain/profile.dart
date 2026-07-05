import '../../auth/domain/app_role.dart';

class Profile {
  const Profile({
    required this.id,
    required this.role,
    required this.createdAt,
    this.fullName,
    this.phone,
  });

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        fullName: map['full_name'] as String?,
        phone: map['phone'] as String?,
        role: AppRole.fromDb(map['role'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  final String id;
  final String? fullName;
  final String? phone;
  final AppRole role;
  final DateTime createdAt;
}
