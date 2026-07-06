class Review {
  const Review({
    required this.id,
    required this.requestId,
    required this.providerId,
    required this.customerId,
    required this.rating,
    required this.createdAt,
    this.comment,
  });

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        id: map['id'] as String,
        requestId: map['request_id'] as String,
        providerId: map['provider_id'] as String,
        customerId: map['customer_id'] as String,
        rating: (map['rating'] as num).toInt(),
        comment: map['comment'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  final String id;
  final String requestId;
  final String providerId;
  final String customerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
}
