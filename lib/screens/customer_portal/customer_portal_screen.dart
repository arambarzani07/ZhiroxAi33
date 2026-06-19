import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../core/widgets/responsive_dashboard_grid.dart';
import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/customer_portal_service.dart';
import '../../services/ledger_query_service.dart';
import '../../services/receipt_service.dart';

class CustomerPortalScreen extends StatefulWidget {
  const CustomerPortalScreen({super.key});

  @override
  State<CustomerPortalScreen> createState() => _CustomerPortalScreenState();
}

class _CustomerPortalScreenState extends State<CustomerPortalScreen> {
  final _service = CustomerPortalService();
  late Future<CustomerPortalSnapshot> _portalFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final userId = context.read<AppStateProvider>().userId;
    if (userId == null || userId.isEmpty) {
      _portalFuture = Future.error(StateError('ناسنامەی کڕیار نەدۆزرایەوە.'));
      return;
    }
    _portalFuture = _service.loadPortal(customerUserId: userId);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _portalFuture;
  }

  String _money(double value, {String currency = 'IQD'}) {
    return '${value.toStringAsFixed(0)} $currency';
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'بێ بەروار';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _entryLabel(String type) {
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
        return 'balance ـی دەستپێک';
      default:
        return type.isEmpty ? 'کردار' : type;
    }
  }

  String _receiptTypeLabel(String type) {
    switch (type) {
      case 'debt':
        return 'وەسڵی قەرز';
      case 'payment':
        return 'وەسڵی پارەدانەوە';
      default:
        return type.isEmpty ? 'وەسڵ' : type;
    }
  }

  void _showQr(ReceiptRecord receipt) {
    final qrData = receipt.verificationUrl.isEmpty ? receipt.verificationCode : receipt.verificationUrl;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(receipt.receiptNumber),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: qrData, size: 220),
            const SizedBox(height: 12),
            SelectableText(receipt.verificationCode),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('داخستن'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canViewCustomerPortal(role)) {
      return const AccessDeniedView(
        title: 'دەستڕاگەیشتن ڕێگەپێنەدراوە',
        message: 'ئەم پۆرتاڵە تەنها بۆ کڕیارەکانە.',
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('پۆرتاڵی کڕیار')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<CustomerPortalSnapshot>(
          future: _portalFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('هەڵە: ${snapshot.error}'))]);
            }

            final portal = snapshot.data!;
            return ListView(
              children: [
                ZhiroxPageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'بەخێربێیت، ${portal.customer.name}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('ئەم پۆرتاڵە تەنها بۆ بینینی balance، ledger و وەسڵەکانی خۆتە. هیچ کردارێکی دارایی لێرە ناکرێت.'),
                      const SizedBox(height: 18),
                      ResponsiveDashboardGrid(
                        children: [
                          _PortalStatCard(title: 'قەرزی ئێستا', value: _money(portal.currentBalance), icon: Icons.account_balance_wallet_outlined),
                          _PortalStatCard(title: 'سنووری قەرز', value: _money(portal.creditLimit), icon: Icons.credit_score_outlined),
                          _PortalStatCard(title: 'سنووری بەردەست', value: _money(portal.availableCredit), icon: Icons.verified_outlined),
                          _PortalStatCard(title: 'ژمارەی وەسڵ', value: portal.receipts.length.toString(), icon: Icons.receipt_long_outlined),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(title: 'دوایین ledger'),
                      const SizedBox(height: 10),
                      if (portal.ledgerItems.isEmpty)
                        const _EmptyCard(message: 'هێشتا هیچ ledger ـێک نییە.')
                      else
                        ...portal.ledgerItems.take(8).map((item) => _LedgerCard(
                              item: item,
                              title: _entryLabel(item.entryType),
                              dateText: _dateText(item.createdAt),
                            )),
                      const SizedBox(height: 22),
                      _SectionTitle(title: 'دوایین وەسڵەکان'),
                      const SizedBox(height: 10),
                      if (portal.receipts.isEmpty)
                        const _EmptyCard(message: 'هێشتا هیچ وەسڵێک نییە.')
                      else
                        ...portal.receipts.take(8).map((receipt) => _PortalReceiptCard(
                              receipt: receipt,
                              typeLabel: _receiptTypeLabel(receipt.receiptType),
                              dateText: _dateText(receipt.createdAt),
                              onQr: () => _showQr(receipt),
                            )),
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

class _PortalStatCard extends StatelessWidget {
  const _PortalStatCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 14),
            Text(title),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Text(message)));
  }
}

class _LedgerCard extends StatelessWidget {
  const _LedgerCard({required this.item, required this.title, required this.dateText});

  final LedgerTimelineItem item;
  final String title;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.timeline_outlined),
        title: Text(title),
        subtitle: Text('بڕ: ${item.amount.toStringAsFixed(0)} ${item.currency}\nپێشوو: ${item.previousBalance.toStringAsFixed(0)} — نوێ: ${item.newBalance.toStringAsFixed(0)}\n$dateText'),
        isThreeLine: true,
      ),
    );
  }
}

class _PortalReceiptCard extends StatelessWidget {
  const _PortalReceiptCard({required this.receipt, required this.typeLabel, required this.dateText, required this.onQr});

  final ReceiptRecord receipt;
  final String typeLabel;
  final String dateText;
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(receipt.receiptNumber),
        subtitle: Text('$typeLabel\n${receipt.amount.toStringAsFixed(0)} ${receipt.currency}\n$dateText'),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'QR',
          onPressed: onQr,
          icon: const Icon(Icons.qr_code_2_outlined),
        ),
      ),
    );
  }
}
