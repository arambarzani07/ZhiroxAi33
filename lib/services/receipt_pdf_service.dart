import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import 'receipt_service.dart';

class ReceiptPdfService {
  Future<Uint8List> buildReceiptPdf(ReceiptRecord receipt) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Zhirox AI Debt Receipt', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Receipt No: ${receipt.receiptNumber}'),
            pw.Text('Type: ${receipt.receiptType}'),
            pw.Text('Customer ID: ${receipt.customerId}'),
            pw.Text('Amount: ${receipt.amount.toStringAsFixed(0)} ${receipt.currency}'),
            pw.Text('Verification Code: ${receipt.verificationCode}'),
            pw.Text('Verification URL: ${receipt.verificationUrl}'),
            if (receipt.createdAt != null) pw.Text('Created: ${receipt.createdAt!.toIso8601String()}'),
            pw.SizedBox(height: 24),
            pw.Text('This receipt is generated from the official Zhirox AI Debt ledger.'),
          ],
        ),
      ),
    );

    return doc.save();
  }
}
