import 'customer_service.dart';
import 'ledger_query_service.dart';
import 'receipt_service.dart';

class CustomerPortalSnapshot {
  const CustomerPortalSnapshot({
    required this.customer,
    required this.ledgerItems,
    required this.receipts,
  });

  final CustomerOption customer;
  final List<LedgerTimelineItem> ledgerItems;
  final List<ReceiptRecord> receipts;

  double get currentBalance => customer.currentBalance;
  double get creditLimit => customer.creditLimit;
  double get availableCredit => (creditLimit - currentBalance).clamp(0, double.infinity).toDouble();
}

class CustomerPortalService {
  final CustomerService _customerService = CustomerService();
  final LedgerQueryService _ledgerQueryService = LedgerQueryService();
  final ReceiptService _receiptService = ReceiptService();

  Future<CustomerPortalSnapshot> loadPortal({required String customerUserId}) async {
    final customer = await _customerService.getCustomer(customerUserId);
    final results = await Future.wait([
      _ledgerQueryService.listCustomerTimeline(customerId: customerUserId),
      _receiptService.listCustomerReceipts(customerId: customerUserId),
    ]);

    return CustomerPortalSnapshot(
      customer: customer,
      ledgerItems: results[0] as List<LedgerTimelineItem>,
      receipts: results[1] as List<ReceiptRecord>,
    );
  }
}
