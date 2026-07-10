import 'package:flutter/material.dart';

import '../../../core/theme/glass_colors.dart';
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
      return GlassColors.warning;
    case OfferStatus.accepted:
      return GlassColors.success;
    case OfferStatus.rejected:
      return GlassColors.neutral;
  }
}
