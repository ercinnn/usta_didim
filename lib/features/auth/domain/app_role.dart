enum AppRole {
  customer,
  provider;

  static AppRole fromDb(String value) =>
      AppRole.values.firstWhere((role) => role.name == value);
}
