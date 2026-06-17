import 'package:flutter/material.dart';

import '../../services/customer_score_query_service.dart';
import '../../services/customer_service.dart';

class CustomerRiskPanel extends StatefulWidget {
  const CustomerRiskPanel({
    super.key,
    required this.customer,
    required this.marketId,
  });

  final CustomerOption customer;
  final String? marketId;

  @override
  State<CustomerRiskPanel> createState() => _CustomerRiskPanelState();
}

class _CustomerRiskPanelState extends State<CustomerRiskPanel> {
  final _service = CustomerScoreQueryService();
  late Future<CustomerRiskSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _service.loadSnapshot(
      customer: widget.customer,
      marketId: widget.marketId,
    );
  }

  Color _riskColor(BuildContext context, String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'diamond':
        return Colors.blueGrey;
      case 'gold':
        return Colors.amber.shade700;
      case 'watch':
        return Colors.orange;
      case 'delay':
        return Colors.deepOrange;
      case 'risk':
        return Colors.red;
      case 'frozen':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _riskLabel(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'diamond':
        return 'Diamond';
      case 'gold':
        return 'Gold';
      case 'watch':
        return 'Watch';
      case 'delay':
        return 'Delay';
      case 'risk':
        return 'Risk';
      case 'frozen':
        return 'Frozen';
      default:
        return riskLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerRiskSnapshot>(
      future: _snapshotFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: LinearProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text('هەڵە لە خوێندنەوەی score: ${snapshot.error}'),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        final riskColor = _riskColor(context, data.riskLevel);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, color: riskColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Trust / Risk Intelligence',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(_riskLabel(data.riskLevel)),
                      backgroundColor: riskColor.withOpacity(0.12),
                      side: BorderSide(color: riskColor.withOpacity(0.35)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(data.fromDatabase ? 'داتاکە لە customer_scores خوێنراوەتەوە.' : 'داتاکە بە fallback هەڵسەنگاندن دروستکراوە تا score collection ئامادە دەبێت.'),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ScoreBox(title: 'Trust Score', value: data.trustScore, color: riskColor),
                    _ScoreBox(title: 'Debt Truth', value: data.debtTruthScore, color: Colors.indigo),
                    _ScoreBox(title: 'Evidence Quality', value: data.evidenceQuality, color: Colors.teal),
                    _ScoreBox(title: 'Promise Reputation', value: data.promiseReputation, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 18),
                _InfoRow(label: 'Credit Limit Status', value: data.creditLimitStatus),
                _InfoRow(label: 'Risk Reason', value: data.riskReason),
                _InfoRow(label: 'System Recommendation', value: data.systemRecommendation),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox({required this.title, required this.value, required this.color});

  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0, 100);
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            '$safeValue/100',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: safeValue / 100),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '-' : value),
        ],
      ),
    );
  }
}
