import 'pb_client.dart';

class LedgerTimelineItem {
  const LedgerTimelineItem({
    required this.id,
    required this.entryType,
    required this.amount,
    required this.previousBalance,
    required this.newBalance,
    required this.currency,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String entryType;
  final double amount;
  final double previousBalance;
  final double newBalance;
  final String currency;
  final String reason;
  final DateTime? createdAt;
}

class LedgerQueryService {
  Future<List<LedgerTimelineItem>> listCustomerTimeline({
    required String customerId,
    String? marketId,
  }) async {
    final marketPart = marketId == null || marketId.isEmpty ? '' : ' && market_id = "$marketId"';
    final records = await PBClient.instance.collection('debt_ledger_entries').getFullList(
          filter: 'customer_id = "$customerId"$marketPart',
          sort: '-created',
        );

    return records.map((record) {
      final data = record.data;
      return LedgerTimelineItem(
        id: record.id,
        entryType: (data['entry_type'] ?? '').toString(),
        amount: (data['amount'] as num?)?.toDouble() ?? 0,
        previousBalance: (data['previous_balance'] as num?)?.toDouble() ?? 0,
        newBalance: (data['new_balance'] as num?)?.toDouble() ?? 0,
        currency: (data['currency'] ?? 'IQD').toString(),
        reason: (data['reason'] ?? '').toString(),
        createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
      );
    }).toList();
  }
}
