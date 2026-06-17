enum SystemRole {
  systemOwner,
  marketManager,
  employee,
  customer;

  static SystemRole fromString(String value) {
    switch (value) {
      case 'system_owner':
        return SystemRole.systemOwner;
      case 'admin':
      case 'market_manager':
        return SystemRole.marketManager;
      case 'employee':
        return SystemRole.employee;
      case 'customer':
        return SystemRole.customer;
      default:
        return SystemRole.customer;
    }
  }

  String get storageValue {
    switch (this) {
      case SystemRole.systemOwner:
        return 'system_owner';
      case SystemRole.marketManager:
        return 'market_manager';
      case SystemRole.employee:
        return 'employee';
      case SystemRole.customer:
        return 'customer';
    }
  }
}
