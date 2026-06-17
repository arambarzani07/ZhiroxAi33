import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../services/customer_service.dart';
import '../../services/receipt_service.dart';

class ReceiptHistoryScreen extends StatefulWidget {
  const ReceiptHistoryScreen({
    super.key,
    required this.customer,
    required this.marketId,
  });

  final CustomerOption customer;
  final String? marketId;

  @override
  State<ReceiptHistoryScreen> createState() => _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends State<ReceiptHistoryScreen> {
  final _receiptService = ReceiptService();
  late Future<List<ReceiptRecord>> _receiptsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _receiptsFuture = _receiptService.listCustomerReceipts(
      customerId: widget.customer.id,
      marketId: widget.marketId,
    );
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _receiptsFuture;
  }

  String _typeLabel(String type) {
    if (type == 'debt') return 'وەسڵی قەرز';
    if (type == 'payment') return 'وەسڵی پارەدانەوە';
    return type.isEmpty ? 'وەسڵ' : type;
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'بێ بەروار';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('داخستن')),
        ],
      ),
    );
  }

  void _showPdfInfo(ReceiptRecord receipt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF foundation ئامادەیە بۆ وەسڵ: ${receipt.receiptNumber}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('وەسڵەکان')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ReceiptRecord>>(
          future: _receiptsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('هەڵە: ${snapshot.error}'))]);
            }

            final receipts = snapshot.data ?? const <ReceiptRecord>[];
            return ListView(
              children: [
                ZhiroxPageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'مێژووی وەسڵەکانی ${widget.customer.name}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('هەر وەسڵێک verification code و QR ـی تایبەتی هەیە.'),
                      const SizedBox(height: 18),
                      if (receipts.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('هێشتا وەسڵی تۆمارکراو نییە.'),
                          ),
                        )
                      else
                        ...receipts.map(
                          (receipt) => _ReceiptCard(
                            receipt: receipt,
                            typeLabel: _typeLabel(receipt.receiptType),
                            dateText: _dateText(receipt.createdAt),
                            onQr: () => _showQr(receipt),
                            onPdf: () => _showPdfInfo(receipt),
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

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.receipt, required this.typeLabel, required this.dateText, required this.onQr, required this.onPdf});

  final ReceiptRecord receipt;
  final String typeLabel;
  final String dateText;
  final VoidCallback onQr;
  final VoidCallback onPdf;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [const Icon(Icons.receipt_long), const SizedBox(width: 10), Expanded(child: Text(receipt.receiptNumber)), Chip(label: Text(typeLabel))]),
            const SizedBox(height: 10),
            Text('بڕ: ${receipt.amount.toStringAsFixed(0)} ${receipt.currency}'),
            Text('کات: $dateText'),
            Text('Verification: ${receipt.verificationCode}'),
            const SizedBox(height: 12),
            Wrap(spacing: 10, children: [
              OutlinedButton.icon(onPressed: onQr, icon: const Icon(Icons.qr_code_2), label: const Text('QR')),
              FilledButton.icon(onPressed: onPdf, icon: const Icon(Icons.picture_as_pdf), label: const Text('PDF')),
            ]),
          ],
        ),
      ),
    );
  }
}
