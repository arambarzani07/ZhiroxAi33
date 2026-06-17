import 'pb_client.dart';

class CustomerOption {
  const CustomerOption({
    required this.id,
    required this.name,
    required this.currentBalance,
    required this.creditLimit,
    required this.overdueCount,
  });

  final String id;
  final String name;
  final double currentBalance;
  final double creditLimit;
  final int overdueCount;
}

class CustomerService {
  Future<List<CustomerOption>> listCustomers({String? marketId}) async {
    final filter = marketId == null || marketId.isEmpty
        ? 'role = "customer" || system_role = "customer"'
        : '(market_id = "$marketId") && (role = "customer" || system_role = "customer")';

    final records = await PBClient.instance.collection('users').getFullList(
          filter: filter,
          sort: 'name',
        );

    return records.map((record) {
      final data = record.data;
      final name = (data['full_name'] ?? data['name'] ?? data['phone'] ?? 'کڕیار').toString();
      return CustomerOption(
        id: record.id,
        name: name,
        currentBalance: (data['current_balance'] as num?)?.toDouble() ?? 0,
        creditLimit: (data['debt_limit'] as num?)?.toDouble() ?? 0,
        overdueCount: (data['overdue_count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}
