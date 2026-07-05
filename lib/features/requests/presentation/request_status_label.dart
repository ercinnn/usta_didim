import '../domain/service_request_status.dart';

String serviceRequestStatusLabel(ServiceRequestStatus status) {
  switch (status) {
    case ServiceRequestStatus.open:
      return 'Açık';
    case ServiceRequestStatus.pending:
      return 'Beklemede';
    case ServiceRequestStatus.completed:
      return 'Tamamlandı';
    case ServiceRequestStatus.cancelled:
      return 'İptal Edildi';
  }
}
