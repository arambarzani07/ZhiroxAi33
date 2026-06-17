import 'package:intl/intl.dart';

import 'pb_client.dart';

class DashboardStats {
  const DashboardStats({
    required this.totalDebt,
    required this.remainingDebt,
    required this.totalPayments,
    required this.totalCustomers,
  });

  final double totalDebt;
  final double remainingDebt;
  final double totalPayments;
  final int totalCustomers;

  factory DashboardStats.empty() => const DashboardStats(
        totalDebt: 0,
        remainingDebt: 0,
        totalPayments: 0,
        totalCustomers: 0,
      );

  String get totalDebtText => _money(totalDebt);
  String get remainingDebtText => _money(remainingDebt);
  String get totalPaymentsText => _money(totalPayments);

  static String _money(double value) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(value)} د.ع';
  }
}

class DashboardService {
  Future<DashboardStats> loadStats({String? marketId}) async {
    final marketFilter = marketId == null || marketId.isEmpty ? '' : 'market_id = "$marketId"';

    final debts = await PBClient.instance.collection('debts').getFullList(
          filter: marketFilter,
          sort: '-created',
        );
    final payments = await PBClient.instance.collection('payments').getFullList(
          filter: marketFilter,
          sort: '-created',
        );
    final users = await PBClient.instance.collection('users').getFullList(
          filter: marketFilter.isEmpty
              ? 'role = "customer" || system_role = "customer"'
              : '($marketFilter) && (role = "customer" || system_role = "customer")',
        );

    double totalDebt = 0;
    double remainingDebt = 0;
    for (final debt in debts) {
      totalDebt += (debt.data['amount'] as num?)?.toDouble() ?? 0;
      remainingDebt += (debt.data['remaining'] as num?)?.toDouble() ?? 0;
    }

    double totalPayments = 0;
    for (final payment in payments) {
      totalPayments += (payment.data['amount'] as num?)?.toDouble() ?? 0;
    }

    return DashboardStats(
      totalDebt: totalDebt,
      remainingDebt: remainingDebt,
      totalPayments: totalPayments,
      totalCustomers: users.length,
    );
  }
}
