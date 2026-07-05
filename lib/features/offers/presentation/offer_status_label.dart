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
