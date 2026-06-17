enum LedgerEntryType {
  debtCreated,
  paymentReceived,
  correction,
  discount,
  forgiveness,
  openingBalance;

  String get storageValue {
    switch (this) {
      case LedgerEntryType.debtCreated:
        return 'debt_created';
      case LedgerEntryType.paymentReceived:
        return 'payment_received';
      case LedgerEntryType.correction:
        return 'correction';
      case LedgerEntryType.discount:
        return 'discount';
      case LedgerEntryType.forgiveness:
        return 'forgiveness';
      case LedgerEntryType.openingBalance:
        return 'opening_balance';
    }
  }
}
