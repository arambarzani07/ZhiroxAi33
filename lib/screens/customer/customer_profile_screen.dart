import 'package:flutter/material.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../services/customer_service.dart';
import '../../services/ledger_query_service.dart';
import 'customer_risk_panel.dart';
import 'smart_lock_panel.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    required this.customer,
    required this.marketId,
  });

  final CustomerOption customer;
  final String? marketId;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _ledgerQueryService = LedgerQueryService();
  late Future<List<LedgerTimelineItem>> _timelineFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _timelineFuture = _ledgerQueryService.listCustomerTimeline(
      customerId: widget.customer.id,
      marketId: widget.marketId,
    );
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'بێ بەروار';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _entryTitle(String type) {
    switch (type) {
      case 'debt_created':
        return 'قەرز زیادکرا';
      case 'payment_received':
        return 'پارەدانەوە وەرگیرا';
      case 'correction':
        return 'چاککردنەوە';
      case 'discount':
        return 'داشکاندن';
      case 'forgiveness':
        return 'بەخشین';
      case 'opening_balance':
        return 'قەرزی کۆن / هاوسەنگی دەستپێکردن';
      default:
        return type.isEmpty ? 'کرداری ledger' : type;
    }
  }

  IconData _entryIcon(String type) {
    switch (type) {
      case 'payment_received':
        return Icons.south_west;
      case 'debt_created':
        return Icons.north_east;
      default:
        return Icons.timeline;
    }
  }

  Color? _entryColor(BuildContext context, String type) {
    if (type == 'payment_received') return Colors.green;
    if (type == 'debt_created') return Theme.of(context).colorScheme.primary;
    return null;
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _timelineFuture;
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    return Scaffold(
      appBar: AppBar(title: const Text('پڕۆفایلی کڕیار')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<LedgerTimelineItem>>(
          future: _timelineFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('هەڵە لە خوێندنەوەی ledger: ${snapshot.error}'),
                  ),
                ],
              );
            }

            final timeline = snapshot.data ?? const <LedgerTimelineItem>[];
            return ListView(
              children: [
                ZhiroxPageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CustomerHeader(customer: customer),
                      const SizedBox(height: 20),
                      CustomerRiskPanel(
                        customer: customer,
                        marketId: widget.marketId,
                      ),
                      const SizedBox(height: 20),
                      SmartLockPanel(
                        customer: customer,
                        marketId: widget.marketId,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ledger Timeline',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('مێژووی فەرمیی قەرز و پارەدانەوەی ئەم کڕیارە.'),
                      const SizedBox(height: 16),
                      if (timeline.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('هێشتا ledger entry بۆ ئەم کڕیارە نییە.'),
                          ),
                        )
                      else
                        ...timeline.map(
                          (item) => _LedgerCard(
                            item: item,
                            title: _entryTitle(item.entryType),
                            dateText: _dateText(item.createdAt),
                            icon: _entryIcon(item.entryType),
                            color: _entryColor(context, item.entryType),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({required this.customer});

  final CustomerOption customer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(customer.name.isEmpty ? '?' : customer.name.characters.first),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Customer Debt Passport — ${customer.id}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MiniStat(title: 'قەرزی ئێستا', value: customer.currentBalance.toStringAsFixed(0)),
                _MiniStat(title: 'سنووری قەرز', value: customer.creditLimit.toStringAsFixed(0)),
                _MiniStat(title: 'دواکەوتن', value: customer.overdueCount.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LedgerCard extends StatelessWidget {
  const _LedgerCard({
    required this.item,
    required this.title,
    required this.dateText,
    required this.icon,
    required this.color,
  });

  final LedgerTimelineItem item;
  final String title;
  final String dateText;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color?.withOpacity(0.12),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(dateText),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _ChipText(label: 'بڕ', value: '${item.amount.toStringAsFixed(0)} ${item.currency}'),
                      _ChipText(label: 'پێشتر', value: item.previousBalance.toStringAsFixed(0)),
                      _ChipText(label: 'دوای', value: item.newBalance.toStringAsFixed(0)),
                    ],
                  ),
                  if (item.reason.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('هۆکار: ${item.reason}'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipText extends StatelessWidget {
  const _ChipText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
