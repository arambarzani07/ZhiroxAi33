import '../core/config/app_config.dart';
import 'pb_client.dart';

class CustomerOption {
  const CustomerOption({
    required this.id,
    required this.name,
    required this.currentBalance,
    required this.creditLimit,
    required this.overdueCount,
    this.phone,
    this.portalEnabled = false,
  });

  final String id;
  final String name;
  final double currentBalance;
  final double creditLimit;
  final int overdueCount;
  final String? phone;
  final bool portalEnabled;
}

class CustomerUpsertRequest {
  const CustomerUpsertRequest({
    required this.name,
    required this.phone,
    required this.marketId,
    required this.creditLimit,
    required this.portalEnabled,
    this.customerCode,
    this.password,
    this.currentBalance = 0,
  });

  final String name;
  final String phone;
  final String marketId;
  final double creditLimit;
  final bool portalEnabled;
  final String? customerCode;
  final String? password;
  final double currentBalance;
}

class CustomerService {
  static const List<CustomerOption> _preDatabaseCustomers = [
    CustomerOption(
      id: 'demo_customer_1',
      name: 'کڕیاری دێمۆ ١',
      currentBalance: 275000,
      creditLimit: 500000,
      overdueCount: 0,
      phone: '07501234561',
      portalEnabled: true,
    ),
    CustomerOption(
      id: 'demo_customer_2',
      name: 'کڕیاری دێمۆ ٢',
      currentBalance: 600000,
      creditLimit: 750000,
      overdueCount: 2,
      phone: '07501234562',
      portalEnabled: true,
    ),
    CustomerOption(
      id: 'pre_database_manager',
      name: 'بەڕێوەبەری دێمۆ',
      currentBalance: 0,
      creditLimit: 0,
      overdueCount: 0,
      phone: '07500000000',
      portalEnabled: true,
    ),
  ];

  Future<List<CustomerOption>> listCustomers({String? marketId}) async {
    if (AppConfig.preDatabaseMode) {
      return _preDatabaseCustomers.where((customer) => customer.id != AppConfig.preDatabaseUserId).toList();
    }

    final filter = marketId == null || marketId.isEmpty
        ? 'role = "customer" || system_role = "customer"'
        : '(market_id = "$marketId") && (role = "customer" || system_role = "customer")';

    final records = await PBClient.instance.collection('users').getFullList(
          filter: filter,
          sort: 'name',
        );

    return records.map(_customerFromRecord).toList();
  }

  Future<CustomerOption> getCustomer(String id) async {
    if (AppConfig.preDatabaseMode) {
      return _preDatabaseCustomers.firstWhere(
        (customer) => customer.id == id,
        orElse: () => _preDatabaseCustomers.first,
      );
    }

    final record = await PBClient.instance.collection('users').getOne(id);
    return _customerFromRecord(record);
  }

  Future<CustomerOption> createCustomer(CustomerUpsertRequest request) async {
    if (AppConfig.preDatabaseMode) {
      return CustomerOption(
        id: 'demo_customer_${DateTime.now().millisecondsSinceEpoch}',
        name: request.name.trim(),
        currentBalance: request.currentBalance,
        creditLimit: request.creditLimit,
        overdueCount: 0,
        phone: request.phone.trim(),
        portalEnabled: request.portalEnabled,
      );
    }

    final body = _bodyFromRequest(request, isCreate: true);
    final record = await PBClient.instance.collection('users').create(body: body);
    return _customerFromRecord(record);
  }

  Future<CustomerOption> updateCustomer(String id, CustomerUpsertRequest request) async {
    if (AppConfig.preDatabaseMode) {
      return CustomerOption(
        id: id,
        name: request.name.trim(),
        currentBalance: request.currentBalance,
        creditLimit: request.creditLimit,
        overdueCount: 0,
        phone: request.phone.trim(),
        portalEnabled: request.portalEnabled,
      );
    }

    final body = _bodyFromRequest(request, isCreate: false);
    final record = await PBClient.instance.collection('users').update(id, body: body);
    return _customerFromRecord(record);
  }

  Map<String, dynamic> _bodyFromRequest(CustomerUpsertRequest request, {required bool isCreate}) {
    final trimmedName = request.name.trim();
    final trimmedPhone = request.phone.trim();
    final trimmedPassword = request.password?.trim() ?? '';
    final customerCode = request.customerCode?.trim().isNotEmpty == true
        ? request.customerCode!.trim()
        : 'CUS-${DateTime.now().millisecondsSinceEpoch}';

    final body = <String, dynamic>{
      'name': trimmedName,
      'full_name': trimmedName,
      'phone': trimmedPhone,
      'username': trimmedPhone,
      'role': 'customer',
      'system_role': 'customer',
      'market_id': request.marketId,
      'debt_limit': request.creditLimit,
      'credit_limit': request.creditLimit,
      'customer_code': customerCode,
      'portal_enabled': request.portalEnabled,
      'active': true,
      'approved': true,
    };

    if (isCreate) {
      body['current_balance'] = request.currentBalance;
      body['overdue_count'] = 0;
    }

    if (trimmedPassword.isNotEmpty) {
      body['password'] = trimmedPassword;
      body['passwordConfirm'] = trimmedPassword;
    }

    return body;
  }

  CustomerOption _customerFromRecord(dynamic record) {
    final data = record.data as Map<String, dynamic>? ?? const {};
    final name = (data['full_name'] ?? data['name'] ?? data['phone'] ?? 'کڕیار').toString();
    return CustomerOption(
      id: record.id.toString(),
      name: name,
      currentBalance: (data['current_balance'] as num?)?.toDouble() ?? 0,
      creditLimit: (data['debt_limit'] as num?)?.toDouble() ?? (data['credit_limit'] as num?)?.toDouble() ?? 0,
      overdueCount: (data['overdue_count'] as num?)?.toInt() ?? 0,
      phone: data['phone']?.toString(),
      portalEnabled: data['portal_enabled'] == true,
    );
  }
}
