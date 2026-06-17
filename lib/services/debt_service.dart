import '../core/enums/ledger_entry_type.dart';
import 'audit_service.dart';
import 'ledger_service.dart';
import 'pb_client.dart';
import 'risk_service.dart';

class DebtService {
  DebtService({
    AuditService? auditService,
    LedgerService? ledgerService,
    RiskService? riskService,
  })  : _auditService = auditService ?? AuditService(),
        _ledgerService = ledgerService ?? LedgerService(),
        _riskService = riskService ?? RiskService();

  final AuditService _auditService;
  final LedgerService _ledgerService;
  final RiskService _riskService;

  Future<String> createDebt({
    required String marketId,
    required String customerId,
    required String createdBy,
    required double amount,
    required double currentBalance,
    required double creditLimit,
    required int overdueCount,
    required String currency,
    required String description,
    DateTime? dueDate,
  }) async {
    final risk = _riskService.evaluateDebtRequest(
      currentBalance: currentBalance,
      newDebtAmount: amount,
      creditLimit: creditLimit,
      overdueCount: overdueCount,
    );

    final newBalance = currentBalance + amount;
    final debt = await PBClient.instance.collection('debts').create(body: {
      'market_id': marketId,
      'customer': customerId,
      'created_by': createdBy,
      'amount': amount,
      'remaining': amount,
      'currency': currency,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'status': 'pending',
      'ledger_locked': true,
      'risk_level_at_creation': risk.riskLevel,
      'trust_score_at_creation': risk.trustScore,
      'requires_approval': risk.requiresApproval,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _ledgerService.record(
      marketId: marketId,
      customerId: customerId,
      debtId: debt.id,
      entryType: LedgerEntryType.debtCreated,
      amount: amount,
      previousBalance: currentBalance,
      newBalance: newBalance,
      currency: currency,
      createdBy: createdBy,
      reason: description,
    );

    await _auditService.log(
      marketId: marketId,
      actorUserId: createdBy,
      actionType: 'debt_created',
      entityType: 'debt',
      entityId: debt.id,
      afterValue: {
        'amount': amount,
        'customer_id': customerId,
        'risk_level': risk.riskLevel,
      },
      reason: description,
    );

    return debt.id;
  }
}
