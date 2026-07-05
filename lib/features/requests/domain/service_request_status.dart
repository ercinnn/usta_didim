enum ServiceRequestStatus {
  open,
  pending,
  completed,
  cancelled;

  static ServiceRequestStatus fromDb(String value) =>
      ServiceRequestStatus.values.firstWhere((status) => status.name == value);
}
