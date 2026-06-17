import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../services/customer_service.dart';
import '../../services/smart_lock_query_service.dart';

class SmartLockPanel extends StatefulWidget {
  const SmartLockPanel({
    super.key,
    required this.customer,
    required this.marketId,
  });

  final CustomerOption customer;
  final String? marketId;

  @override
  State<SmartLockPanel> createState() => _SmartLockPanelState();
}

class _SmartLockPanelState extends State<SmartLockPanel> {
  final _service = SmartLockQueryService();
  late Future<_SmartLockViewData> _dataFuture;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _dataFuture = _load();
  }

  Future<_SmartLockViewData> _load() async {
    final lock = await _service.getCustomerLock(
      customerId: widget.customer.id,
      marketId: widget.marketId,
    );
    final history = await _service.listHistory(
      customerId: widget.customer.id,
      marketId: widget.marketId,
    );
    return _SmartLockViewData(lock: lock, history: history);
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'بێ بەروار';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _requestUnlock() async {
    final appState = context.read<AppStateProvider>();
    final marketId = widget.marketId ?? appState.marketId;
    final userId = appState.userId;
    if (marketId == null || marketId.isEmpty || userId == null || userId.isEmpty) {
      _showMessage('هەڵە: market_id یان user_id نەدۆزرایەوە.');
      return;
    }

    final reason = await _askReason();
    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _requesting = true);
    try {
      final approvalId = await _service.requestUnlock(
        marketId: marketId,
        requestedBy: userId,
        customerId: widget.customer.id,
        reason: reason.trim(),
      );
      if (!mounted) return;
      _showMessage('داواکاری کردنەوەی قفڵ نێردرا بۆ Approval Center. ID: $approvalId');
    } catch (error) {
      if (!mounted) return;
      _showMessage('هەڵە لە ناردنی داواکاری unlock: $error');
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<String?> _askReason() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('داواکاری کردنەوەی قفڵ'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'هۆکاری داواکاری unlock'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('پاشگەزبوونەوە')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('ناردن')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SmartLockViewData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: LinearProgressIndicator(),
            ),
          );
        }

        final data = snapshot.data;
        final lock = data?.lock ?? SmartLockSnapshot.unlocked();
        final history = data?.history ?? const <SmartLockHistoryItem>[];
        final lockedColor = lock.locked ? Colors.red : Colors.green;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(lock.locked ? Icons.lock : Icons.lock_open, color: lockedColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Smart Debt Lock',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(lock.locked ? 'Locked' : 'Open'),
                      backgroundColor: lockedColor.withOpacity(0.12),
                      side: BorderSide(color: lockedColor.withOpacity(0.35)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(lock.locked
                    ? 'ئەم کڕیارە قفڵکراوە؛ قەرزی نوێ دەبێت ڕابگیرێت یان داواکاری پەسندکردن بکرێت.'
                    : 'ئەم کڕیارە ئێستا قفڵ نییە.'),
                if (lock.locked) ...[
                  const SizedBox(height: 14),
                  _Line(label: 'Risk Level', value: lock.riskLevel),
                  _Line(label: 'هۆکاری قفڵ', value: lock.reason),
                  _Line(label: 'قفڵکراوە لەلایەن', value: lock.lockedBy),
                  _Line(label: 'کات', value: _dateText(lock.createdAt)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _requesting ? null : _requestUnlock,
                    icon: _requesting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.lock_open),
                    label: Text(_requesting ? 'داواکاری دەنێردرێت...' : 'داواکاری کردنەوەی قفڵ'),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  'Lock History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  const Text('هێشتا مێژووی قفڵ نییە.')
                else
                  ...history.take(5).map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history),
                          title: Text(item.action.isEmpty ? 'lock action' : item.action),
                          subtitle: Text('${item.reason}\n${_dateText(item.createdAt)}'),
                          isThreeLine: true,
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}

class _SmartLockViewData {
  const _SmartLockViewData({required this.lock, required this.history});

  final SmartLockSnapshot lock;
  final List<SmartLockHistoryItem> history;
}
