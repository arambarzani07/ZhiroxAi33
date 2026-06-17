import 'customer_service.dart';
import 'pb_client.dart';

class CustomerRiskSnapshot {
  const CustomerRiskSnapshot({
    required this.trustScore,
    required this.riskLevel,
    required this.debtTruthScore,
    required this.evidenceQuality,
    required this.promiseReputation,
    required this.creditLimitStatus,
    required this.riskReason,
    required this.systemRecommendation,
    required this.fromDatabase,
  });

  final int trustScore;
  final String riskLevel;
  final int debtTruthScore;
  final int evidenceQuality;
  final int promiseReputation;
  final String creditLimitStatus;
  final String riskReason;
  final String systemRecommendation;
  final bool fromDatabase;
}

class CustomerScoreQueryService {
  Future<CustomerRiskSnapshot> loadSnapshot({
    required CustomerOption customer,
    String? marketId,
  }) async {
    try {
      final marketPart = marketId == null || marketId.isEmpty ? '' : ' && market_id = "$marketId"';
      final records = await PBClient.instance.collection('customer_scores').getList(
            page: 1,
            perPage: 1,
            filter: 'customer_id = "${customer.id}"$marketPart',
            sort: '-created',
          );

      if (records.items.isNotEmpty) {
        final data = records.items.first.data;
        return CustomerRiskSnapshot(
          trustScore: (data['trust_score'] as num?)?.toInt() ?? 0,
          riskLevel: (data['risk_level'] ?? 'Watch').toString(),
          debtTruthScore: (data['debt_truth_score'] as num?)?.toInt() ?? 0,
          evidenceQuality: (data['evidence_quality'] as num?)?.toInt() ?? 0,
          promiseReputation: (data['promise_reputation'] as num?)?.toInt() ?? 0,
          creditLimitStatus: (data['credit_limit_status'] ?? '').toString(),
          riskReason: (data['risk_reason'] ?? '').toString(),
          systemRecommendation: (data['system_recommendation'] ?? '').toString(),
          fromDatabase: true,
        );
      }
    } catch (_) {
      // If score collection is not created yet, fall back to a safe derived snapshot.
    }

    return _derivedSnapshot(customer);
  }

  CustomerRiskSnapshot _derivedSnapshot(CustomerOption customer) {
    final usage = customer.creditLimit <= 0 ? 1.0 : customer.currentBalance / customer.creditLimit;

    if (customer.overdueCount >= 3 || usage >= 1.2) {
      return const CustomerRiskSnapshot(
        trustScore: 25,
        riskLevel: 'Risk',
        debtTruthScore: 60,
        evidenceQuality: 50,
        promiseReputation: 35,
        creditLimitStatus: 'Over limit',
        riskReason: 'Customer has high overdue count or exceeded credit limit.',
        systemRecommendation: 'Require manager approval before new debt.',
        fromDatabase: false,
      );
    }

    if (customer.overdueCount > 0 || usage >= 0.9) {
      return const CustomerRiskSnapshot(
        trustScore: 55,
        riskLevel: 'Watch',
        debtTruthScore: 70,
        evidenceQuality: 65,
        promiseReputation: 55,
        creditLimitStatus: 'Near limit',
        riskReason: 'Customer is close to credit limit or has overdue history.',
        systemRecommendation: 'Allow only with caution and approval for large debt.',
        fromDatabase: false,
      );
    }

    return const CustomerRiskSnapshot(
      trustScore: 85,
      riskLevel: 'Gold',
      debtTruthScore: 85,
      evidenceQuality: 80,
      promiseReputation: 80,
      creditLimitStatus: 'Healthy',
      riskReason: 'Customer status looks acceptable based on current balance and overdue count.',
      systemRecommendation: 'Normal debt operations can continue within credit limit.',
      fromDatabase: false,
    );
  }
}
