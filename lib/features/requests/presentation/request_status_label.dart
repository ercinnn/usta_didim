import 'package:flutter/material.dart';

import '../../../core/theme/glass_colors.dart';
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

Color serviceRequestStatusColor(ServiceRequestStatus status) {
  switch (status) {
    case ServiceRequestStatus.open:
      return GlassColors.primary;
    case ServiceRequestStatus.pending:
      return GlassColors.warning;
    case ServiceRequestStatus.completed:
      return GlassColors.success;
    case ServiceRequestStatus.cancelled:
      return GlassColors.neutral;
  }
}
