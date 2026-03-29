class AppConstants {
  // Stock warning threshold — products below this are flagged as low stock
  static const int lowStockThreshold = 5;

  // Default admin credentials (seeded into DB on first launch)
  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'admin123';

  // Currency label
  static const String currency = 'GHS';

  // App name
  static const String appName = 'Inventory Manager';
}
