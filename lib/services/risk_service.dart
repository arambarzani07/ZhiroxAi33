class RiskResult {
  const RiskResult({
    required this.trustScore,
    required this.riskLevel,
    required this.requiresApproval,
    required this.explanation,
  });

  final int trustScore;
  final String riskLevel;
  final bool requiresApproval;
  final String explanation;
}

class RiskService {
  RiskResult evaluateDebtRequest({
    required double currentBalance,
    required double newDebtAmount,
    required double creditLimit,
    required int overdueCount,
  }) {
    final projectedBalance = currentBalance + newDebtAmount;
    final usage = creditLimit <= 0 ? 1.0 : projectedBalance / creditLimit;

    if (overdueCount >= 3 || usage >= 1.2) {
      return const RiskResult(
        trustScore: 25,
        riskLevel: 'Risk',
        requiresApproval: true,
        explanation: 'High risk customer. Manager approval is required.',
      );
    }

    if (usage >= 0.9 || overdueCount > 0) {
      return const RiskResult(
        trustScore: 55,
        riskLevel: 'Watch',
        requiresApproval: true,
        explanation: 'Customer is close to credit limit or has overdue history.',
      );
    }

    return const RiskResult(
      trustScore: 85,
      riskLevel: 'Gold',
      requiresApproval: false,
      explanation: 'Customer status is acceptable for normal debt creation.',
    );
  }
}
