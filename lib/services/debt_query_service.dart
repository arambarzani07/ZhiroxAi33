import 'pb_client.dart';

class OpenDebtOption {
  const OpenDebtOption({
    required this.id,
    required this.title,
    required this.remaining,
    required this.currency,
  });

  final String id;
  final String title;
  final double remaining;
  final String currency;
}

class DebtQueryService {
  Future<List<OpenDebtOption>> listOpenDebtsForCustomer({
    required String customerId,
    String? marketId,
  }) async {
    final marketPart = marketId == null || marketId.isEmpty ? '' : ' && market_id = "$marketId"';
    final records = await PBClient.instance.collection('debts').getFullList(
          filter: 'customer = "$customerId" && remaining > 0 && status != "paid"$marketPart',
          sort: '-created',
        );

    return records.map((record) {
      final data = record.data;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final remaining = (data['remaining'] as num?)?.toDouble() ?? amount;
      final description = (data['description'] ?? 'قەرز').toString();
      final currency = (data['currency'] ?? 'IQD').toString();
      return OpenDebtOption(
        id: record.id,
        title: '$description — ${remaining.toStringAsFixed(0)} $currency',
        remaining: remaining,
        currency: currency,
      );
    }).toList();
  }
}
