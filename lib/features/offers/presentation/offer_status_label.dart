import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/offer_status.dart';

String offerStatusLabel(OfferStatus status) {
  switch (status) {
    case OfferStatus.pending:
      return 'Beklemede';
    case OfferStatus.accepted:
      return 'Kabul Edildi';
    case OfferStatus.rejected:
      return 'Reddedildi';
  }
}

Color offerStatusColor(OfferStatus status) {
  switch (status) {
    case OfferStatus.pending:
      return AppColors.navy;
    case OfferStatus.accepted:
      return AppColors.olive;
    case OfferStatus.rejected:
      return AppColors.ink.withValues(alpha: 0.45);
  }
}
