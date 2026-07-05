enum OfferStatus {
  pending,
  accepted,
  rejected;

  static OfferStatus fromDb(String value) =>
      OfferStatus.values.firstWhere((status) => status.name == value);
}
