import 'dart:math';

import '../core/config/app_config.dart';
import 'pb_client.dart';

class ReceiptRecord {
  const ReceiptRecord({
    required this.id,
    required this.receiptNumber,
    required this.receiptType,
    required this.customerId,
    required this.amount,
    required this.currency,
    required this.verificationCode,
    required this.verificationUrl,
    required this.createdAt,
  });

  final String id;
  final String receiptNumber;
  final String receiptType;
  final String customerId;
  final double amount;
  final String currency;
  final String verificationCode;
  final String verificationUrl;
  final DateTime? createdAt;
}

class ReceiptService {
  Future<String> createDebtReceipt({
    required String marketId,
    required String customerId,
    required String debtId,
    required double amount,
    required String currency,
    required String createdBy,
  }) async {
    return _createReceipt(
      marketId: marketId,
      customerId: customerId,
      debtId: debtId,
      paymentId: null,
      receiptType: 'debt',
      amount: amount,
      currency: currency,
      createdBy: createdBy,
    );
  }

  Future<String> createPaymentReceipt({
    required String marketId,
    required String customerId,
    required String debtId,
    required String paymentId,
    required double amount,
    required String currency,
    required String createdBy,
  }) async {
    return _createReceipt(
      marketId: marketId,
      customerId: customerId,
      debtId: debtId,
      paymentId: paymentId,
      receiptType: 'payment',
      amount: amount,
      currency: currency,
      createdBy: createdBy,
    );
  }

  Future<String> _createReceipt({
    required String marketId,
    required String customerId,
    required String debtId,
    required String? paymentId,
    required String receiptType,
    required double amount,
    required String currency,
    required String createdBy,
  }) async {
    final verificationCode = _verificationCode();
    final receiptNumber = _receiptNumber(receiptType);
    final verificationUrl = '${AppConfig.productName.replaceAll(' ', '').toLowerCase()}://verify/$verificationCode';

    final record = await PBClient.instance.collection('receipts').create(body: {
      'market_id': marketId,
      'customer_id': customerId,
      'debt_id': debtId,
      'payment_id': paymentId,
      'receipt_type': receiptType,
      'receipt_number': receiptNumber,
      'amount': amount,
      'currency': currency,
      'verification_code': verificationCode,
      'verification_url': verificationUrl,
      'created_by': createdBy,
      'created_at': DateTime.now().toIso8601String(),
    });

    return record.id;
  }

  Future<List<ReceiptRecord>> listCustomerReceipts({
    required String customerId,
    String? marketId,
  }) async {
    final marketPart = marketId == null || marketId.isEmpty ? '' : ' && market_id = "$marketId"';
    final records = await PBClient.instance.collection('receipts').getFullList(
          filter: 'customer_id = "$customerId"$marketPart',
          sort: '-created',
        );

    return records.map((record) {
      final data = record.data;
      return ReceiptRecord(
        id: record.id,
        receiptNumber: (data['receipt_number'] ?? '').toString(),
        receiptType: (data['receipt_type'] ?? '').toString(),
        customerId: (data['customer_id'] ?? '').toString(),
        amount: (data['amount'] as num?)?.toDouble() ?? 0,
        currency: (data['currency'] ?? 'IQD').toString(),
        verificationCode: (data['verification_code'] ?? '').toString(),
        verificationUrl: (data['verification_url'] ?? '').toString(),
        createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
      );
    }).toList();
  }

  String _receiptNumber(String type) {
    final now = DateTime.now();
    final rand = Random().nextInt(9000) + 1000;
    final prefix = type == 'payment' ? 'PAY' : 'DEBT';
    return '$prefix-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$rand';
  }

  String _verificationCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
