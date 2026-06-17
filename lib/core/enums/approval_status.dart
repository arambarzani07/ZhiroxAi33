enum ApprovalStatus {
  pending,
  approved,
  rejected,
  cancelled;

  String get storageValue {
    switch (this) {
      case ApprovalStatus.pending:
        return 'pending';
      case ApprovalStatus.approved:
        return 'approved';
      case ApprovalStatus.rejected:
        return 'rejected';
      case ApprovalStatus.cancelled:
        return 'cancelled';
    }
  }
}
