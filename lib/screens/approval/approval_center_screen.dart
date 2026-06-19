import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/approval_query_service.dart';

class ApprovalCenterScreen extends StatefulWidget {
  const ApprovalCenterScreen({super.key});

  @override
  State<ApprovalCenterScreen> createState() => _ApprovalCenterScreenState();
}

class _ApprovalCenterScreenState extends State<ApprovalCenterScreen> {
  final _service = ApprovalQueryService();
  late Future<List<ApprovalRequestItem>> _itemsFuture;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final marketId = context.read<AppStateProvider>().marketId;
    _itemsFuture = _service.listPending(marketId: marketId);
  }

  Future<void> _resolve(ApprovalRequestItem item, {required bool approved}) async {
    final userId = context.read<AppStateProvider>().userId;
    if (userId == null || userId.isEmpty) {
      _showMessage('هەڵە: user_id نەدۆزرایەوە.');
      return;
    }

    final note = await _askForNote(approved: approved);
    if (note == null) return;

    setState(() => _working = true);
    try {
      if (approved) {
        await _service.approve(approvalId: item.id, managerUserId: userId, note: note);
      } else {
        await _service.reject(approvalId: item.id, managerUserId: userId, note: note);
      }
      if (!mounted) return;
      _showMessage(approved ? 'داواکارییەکە پەسندکرا.' : 'داواکارییەکە ڕەتکرایەوە.');
      setState(_reload);
    } catch (error) {
      if (!mounted) return;
      _showMessage('هەڵە لە نوێکردنەوەی داواکاری: $error');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<String?> _askForNote({required bool approved}) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approved ? 'پەسندکردنی داواکاری' : 'ڕەتکردنەوەی داواکاری'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'تێبینی بەڕێوەبەر'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('پاشگەزبوونەوە')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('دڵنیام')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _labelForType(String type) {
    switch (type) {
      case 'large_debt':
        return 'قەرزی گەورە';
      case 'risk_customer_debt':
        return 'قەرزی کڕیاری مەترسیدار';
      case 'unlock_customer':
        return 'کردنەوەی قفڵی کڕیار';
      case 'delete_debt':
        return 'سڕینەوەی قەرز';
      case 'change_payment':
        return 'دەستکاری پارەدانەوە';
      case 'discount':
        return 'داشکاندن';
      case 'forgiveness':
        return 'بەخشینی قەرز';
      default:
        return type.isEmpty ? 'داواکاری' : type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Center')),
      body: FutureBuilder<List<ApprovalRequestItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('هەڵە لە خوێندنەوەی داواکارییەکان: ${snapshot.error}'));
          }

          final items = snapshot.data ?? const <ApprovalRequestItem>[];
          return SingleChildScrollView(
            child: ZhiroxPageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ناوەندی پەسندکردن',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('کردارە مەترسیدارەکان لێرە پەسند یان ڕەت دەکرێنەوە.'),
                  const SizedBox(height: 20),
                  if (items.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('هیچ داواکارییەکی چاوەڕوان نییە.'),
                      ),
                    )
                  else
                    ...items.map((item) => _ApprovalCard(
                          item: item,
                          title: _labelForType(item.requestType),
                          working: _working,
                          onApprove: () => _resolve(item, approved: true),
                          onReject: () => _resolve(item, approved: false),
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.item,
    required this.title,
    required this.working,
    required this.onApprove,
    required this.onReject,
  });

  final ApprovalRequestItem item;
  final String title;
  final bool working;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Chip(label: Text(item.status)),
              ],
            ),
            const SizedBox(height: 12),
            Text('جۆری کردار: ${item.entityType}'),
            if (item.amount > 0) Text('بڕ: ${item.amount.toStringAsFixed(0)}'),
            if (item.customerId.isNotEmpty) Text('کڕیار: ${item.customerId}'),
            if (item.reason.isNotEmpty) Text('هۆکار: ${item.reason}'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: working ? null : onApprove,
                  icon: const Icon(Icons.check),
                  label: const Text('پەسندکردن'),
                ),
                OutlinedButton.icon(
                  onPressed: working ? null : onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('ڕەتکردنەوە'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
