class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.businessName,
    required this.category,
    required this.neighborhood,
    required this.isVerified,
    required this.createdAt,
    this.description,
    this.rating,
  });

  factory ProviderProfile.fromMap(Map<String, dynamic> map) => ProviderProfile(
        id: map['id'] as String,
        businessName: map['business_name'] as String,
        category: map['category'] as String,
        description: map['description'] as String?,
        neighborhood: map['neighborhood'] as String,
        isVerified: map['is_verified'] as bool,
        rating: map['rating'] as num?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  final String id;
  final String businessName;
  final String category;
  final String? description;
  final String neighborhood;
  final bool isVerified;
  final num? rating;
  final DateTime createdAt;
}
