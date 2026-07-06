import 'offer_status.dart';

class Offer {
  const Offer({
    required this.id,
    required this.requestId,
    required this.providerId,
    required this.price,
    required this.status,
    required this.createdAt,
    this.note,
    this.providerBusinessName,
    this.providerRating,
    this.providerIsVerified = false,
    this.requestTitle,
    this.requestCategory,
    this.requestNeighborhood,
  });

  factory Offer.fromMap(Map<String, dynamic> map) {
    final provider = map['providers'] as Map<String, dynamic>?;
    final request = map['service_requests'] as Map<String, dynamic>?;
    return Offer(
      id: map['id'] as String,
      requestId: map['request_id'] as String,
      providerId: map['provider_id'] as String,
      price: map['price'] as num,
      note: map['note'] as String?,
      status: OfferStatus.fromDb(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      providerBusinessName: provider?['business_name'] as String?,
      providerRating: provider?['rating'] as num?,
      providerIsVerified: provider?['is_verified'] as bool? ?? false,
      requestTitle: request?['title'] as String?,
      requestCategory: request?['category'] as String?,
      requestNeighborhood: request?['neighborhood'] as String?,
    );
  }

  final String id;
  final String requestId;
  final String providerId;
  final num price;
  final String? note;
  final OfferStatus status;
  final DateTime createdAt;
  final String? providerBusinessName;
  final num? providerRating;
  final bool providerIsVerified;
  final String? requestTitle;
  final String? requestCategory;
  final String? requestNeighborhood;
}
