import '../enums/system_role.dart';

class AppPermissions {
  const AppPermissions._();

  static bool canOpenOwnerPanel(SystemRole? role) {
    return role == SystemRole.systemOwner;
  }

  static bool canUseMarketWorkspace(SystemRole? role) {
    return role == SystemRole.marketManager || role == SystemRole.employee;
  }

  static bool canCreateDebt(SystemRole? role) {
    return role == SystemRole.marketManager || role == SystemRole.employee;
  }

  static bool canReceivePayment(SystemRole? role) {
    return role == SystemRole.marketManager || role == SystemRole.employee;
  }

  static bool canViewCustomers(SystemRole? role) {
    return role == SystemRole.marketManager || role == SystemRole.employee;
  }

  static bool canViewApprovalCenter(SystemRole? role) {
    return role == SystemRole.marketManager;
  }

  static bool canViewAuditLog(SystemRole? role) {
    return role == SystemRole.marketManager;
  }

  static bool canViewSchemaHealth(SystemRole? role) {
    return role == SystemRole.systemOwner;
  }

  static bool canViewCustomerPortal(SystemRole? role) {
    return role == SystemRole.customer;
  }
}
