import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
      return AppColors.navy;
    case ServiceRequestStatus.pending:
      return AppColors.terracotta;
    case ServiceRequestStatus.completed:
      return AppColors.olive;
    case ServiceRequestStatus.cancelled:
      return AppColors.ink.withValues(alpha: 0.45);
  }
}
