import '../core/enums/ledger_entry_type.dart';
import 'audit_service.dart';
import 'ledger_service.dart';
import 'pb_client.dart';

class PaymentService {
  PaymentService({AuditService? auditService, LedgerService? ledgerService})
      : _auditService = auditService ?? AuditService(),
        _ledgerService = ledgerService ?? LedgerService();

  final AuditService _auditService;
  final LedgerService _ledgerService;

  Future<String> receivePayment({
    required String marketId,
    required String customerId,
    required String debtId,
    required String createdBy,
    required double amount,
    required double previousBalance,
    required String currency,
    String? note,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }
    if (amount > previousBalance) {
      throw ArgumentError('Payment amount cannot be greater than remaining debt.');
    }

    final newBalance = previousBalance - amount;
    final payment = await PBClient.instance.collection('payments').create(body: {
      'market_id': marketId,
      'customer_id': customerId,
      'debt': debtId,
      'amount': amount,
      'currency': currency,
      'previous_balance': previousBalance,
      'new_balance': newBalance,
      'created_by': createdBy,
      'note': note ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });

    await PBClient.instance.collection('debts').update(debtId, body: {
      'remaining': newBalance,
      'status': newBalance <= 0 ? 'paid' : 'partial',
    });

    await _ledgerService.record(
      marketId: marketId,
      customerId: customerId,
      debtId: debtId,
      paymentId: payment.id,
      entryType: LedgerEntryType.paymentReceived,
      amount: amount,
      previousBalance: previousBalance,
      newBalance: newBalance,
      currency: currency,
      createdBy: createdBy,
      reason: note,
    );

    await _auditService.log(
      marketId: marketId,
      actorUserId: createdBy,
      actionType: 'payment_received',
      entityType: 'payment',
      entityId: payment.id,
      afterValue: {
        'amount': amount,
        'debt_id': debtId,
        'previous_balance': previousBalance,
        'new_balance': newBalance,
      },
      reason: note,
    );

    return payment.id;
  }
}
