import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/audit_query_service.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final _service = AuditQueryService();
  late Future<List<AuditLogItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final marketId = context.read<AppStateProvider>().marketId;
    _itemsFuture = _service.listRecent(marketId: marketId);
  }

  String _labelForAction(String action) {
    switch (action) {
      case 'debt_created':
        return 'قەرز زیادکرا';
      case 'payment_received':
        return 'پارەدانەوە وەرگیرا';
      case 'approval_approved':
        return 'داواکاری پەسندکرا';
      case 'approval_rejected':
        return 'داواکاری ڕەتکرایەوە';
      case 'debt_deleted':
        return 'قەرز سڕایەوە';
      case 'payment_changed':
        return 'پارەدانەوە دەستکاری کرا';
      default:
        return action.isEmpty ? 'کردار' : action;
    }
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'بێ بەروار';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _itemsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<AuditLogItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('هەڵە لە خوێندنەوەی audit log: ${snapshot.error}'),
                  ),
                ],
              );
            }

            final items = snapshot.data ?? const <AuditLogItem>[];
            return ListView(
              children: [
                ZhiroxPageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'مێژووی کردارە گرنگەکان',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('هیچ کردارێکی گرنگ نابێت بەبێ مێژوو بمێنێت.'),
                      const SizedBox(height: 20),
                      if (items.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('هێشتا audit log نییە.'),
                          ),
                        )
                      else
                        ...items.map(
                          (item) => _AuditLogCard(
                            item: item,
                            actionTitle: _labelForAction(item.actionType),
                            dateText: _dateText(item.createdAt),
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

class _AuditLogCard extends StatelessWidget {
  const _AuditLogCard({
    required this.item,
    required this.actionTitle,
    required this.dateText,
  });

  final AuditLogItem item;
  final String actionTitle;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        leading: const Icon(Icons.history),
        title: Text(actionTitle),
        subtitle: Text('$dateText — ${item.entityType}'),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          _InfoLine(label: 'بەکارهێنەر', value: item.actorUserId),
          _InfoLine(label: 'جۆری کردار', value: item.actionType),
          _InfoLine(label: 'جۆری record', value: item.entityType),
          _InfoLine(label: 'record ID', value: item.entityId),
          if (item.reason.isNotEmpty) _InfoLine(label: 'هۆکار', value: item.reason),
          if (item.beforeValueText.isNotEmpty) _InfoBlock(label: 'پێش کردار', value: item.beforeValueText),
          if (item.afterValueText.isNotEmpty) _InfoBlock(label: 'دوای کردار', value: item.afterValueText),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: SelectableText(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
}
