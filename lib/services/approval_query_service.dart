import 'pb_client.dart';

class ApprovalRequestItem {
  const ApprovalRequestItem({
    required this.id,
    required this.requestType,
    required this.entityType,
    required this.entityId,
    required this.customerId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String requestType;
  final String entityType;
  final String entityId;
  final String customerId;
  final double amount;
  final String reason;
  final String status;
  final DateTime? createdAt;
}

class ApprovalQueryService {
  Future<List<ApprovalRequestItem>> listPending({String? marketId}) async {
    final marketPart = marketId == null || marketId.isEmpty ? '' : ' && market_id = "$marketId"';
    final records = await PBClient.instance.collection('approvals').getFullList(
          filter: 'status = "pending"$marketPart',
          sort: '-created',
        );

    return records.map((record) {
      final data = record.data;
      return ApprovalRequestItem(
        id: record.id,
        requestType: (data['request_type'] ?? '').toString(),
        entityType: (data['entity_type'] ?? '').toString(),
        entityId: (data['entity_id'] ?? '').toString(),
        customerId: (data['customer_id'] ?? '').toString(),
        amount: (data['amount'] as num?)?.toDouble() ?? 0,
        reason: (data['reason'] ?? '').toString(),
        status: (data['status'] ?? 'pending').toString(),
        createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
      );
    }).toList();
  }

  Future<void> approve({
    required String approvalId,
    required String managerUserId,
    String? note,
  }) async {
    await PBClient.instance.collection('approvals').update(approvalId, body: {
      'status': 'approved',
      'resolved_by': managerUserId,
      'manager_note': note ?? '',
      'resolved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> reject({
    required String approvalId,
    required String managerUserId,
    String? note,
  }) async {
    await PBClient.instance.collection('approvals').update(approvalId, body: {
      'status': 'rejected',
      'resolved_by': managerUserId,
      'manager_note': note ?? '',
      'resolved_at': DateTime.now().toIso8601String(),
    });
  }
}
