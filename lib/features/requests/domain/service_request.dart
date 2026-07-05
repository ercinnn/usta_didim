import 'service_request_status.dart';

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.customerId,
    required this.category,
    required this.title,
    required this.neighborhood,
    required this.status,
    required this.createdAt,
    this.description,
    this.preferredDate,
  });

  factory ServiceRequest.fromMap(Map<String, dynamic> map) => ServiceRequest(
        id: map['id'] as String,
        customerId: map['customer_id'] as String,
        category: map['category'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        neighborhood: map['neighborhood'] as String,
        preferredDate: map['preferred_date'] == null
            ? null
            : DateTime.parse(map['preferred_date'] as String),
        status: ServiceRequestStatus.fromDb(map['status'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  final String id;
  final String customerId;
  final String category;
  final String title;
  final String? description;
  final String neighborhood;
  final DateTime? preferredDate;
  final ServiceRequestStatus status;
  final DateTime createdAt;
}
