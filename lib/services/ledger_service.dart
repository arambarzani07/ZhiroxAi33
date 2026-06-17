import '../core/enums/ledger_entry_type.dart';
import 'pb_client.dart';

class LedgerService {
  Future<void> record({
    required String marketId,
    required String customerId,
    String? debtId,
    String? paymentId,
    required LedgerEntryType entryType,
    required double amount,
    required double previousBalance,
    required double newBalance,
    required String currency,
    required String createdBy,
    String? auditLogId,
    String? receiptId,
    String? reason,
  }) async {
    await PBClient.instance.collection('debt_ledger_entries').create(body: {
      'market_id': marketId,
      'customer_id': customerId,
      'debt_id': debtId,
      'payment_id': paymentId,
      'entry_type': entryType.storageValue,
      'amount': amount,
      'previous_balance': previousBalance,
      'new_balance': newBalance,
      'currency': currency,
      'created_by': createdBy,
      'audit_log_id': auditLogId,
      'receipt_id': receiptId,
      'reason': reason ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
