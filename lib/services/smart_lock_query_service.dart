import 'approval_service.dart';
import 'pb_client.dart';

class SmartLockSnapshot {
  const SmartLockSnapshot({
    required this.locked,
    required this.lockId,
    required this.reason,
    required this.riskLevel,
    required this.lockedBy,
    required this.createdAt,
    required this.source,
  });

  final bool locked;
  final String? lockId;
  final String reason;
  final String riskLevel;
  final String lockedBy;
  final DateTime? createdAt;
  final String source;

  factory SmartLockSnapshot.unlocked() => const SmartLockSnapshot(
        locked: false,
        lockId: null,
        reason: '',
        riskLevel: 'Open',
        lockedBy: '',
        createdAt: null,
        source: 'none',
      );
}

class SmartLockHistoryItem {
  const SmartLockHistoryItem({
    required this.id,
    required this.action,
    required this.reason,
    required this.actorUserId,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String reason;
  final String actorUserId;
  final DateTime? createdAt;
}

class SmartLockQueryService {
  final ApprovalService _approvalService = ApprovalService();

  Future<SmartLockSnapshot> getCustomerLock({
    required String customerId,
    String? marketId,
  }) async {
    try {
      final marketPart = marketId == null || marketId.isEmpty ? '' : ' && market_id = "$marketId"';
      final records = await PBClient.instance.collection('smart_locks').getList(
            page: 1,
            perPage: 1,
            filter: 'customer_id = "$customerId" && active = true$marketPart',
            sort: '-created',
          );

      if (records.items.isEmpty) return SmartLockSnapshot.unlocked();
      final record = records.items.first;
      final data = record.data;
      return SmartLockSnapshot(
        locked: true,
        lockId: record.id,
        reason: (data['reason'] ?? '').toString(),
        riskLevel: (data['risk_level'] ?? 'Risk').toString(),
        lockedBy: (data['locked_by'] ?? '').toString(),
        createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
        source: 'smart_locks',
      );
    } catch (_) {
      return SmartLockSnapshot.unlocked();
    }
  }

  Future<List<SmartLockHistoryItem>> listHistory({
    required String customerId,
    String? marketId,
  }) async {
    try {
      final marketPart = marketId == null || marketId.isEmpty ? '' : ' && market_id = "$marketId"';
      final records = await PBClient.instance.collection('lock_history').getFullList(
            filter: 'customer_id = "$customerId"$marketPart',
            sort: '-created',
          );

      return records.map((record) {
        final data = record.data;
        return SmartLockHistoryItem(
          id: record.id,
          action: (data['action'] ?? '').toString(),
          reason: (data['reason'] ?? '').toString(),
          actorUserId: (data['actor_user_id'] ?? '').toString(),
          createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
        );
      }).toList();
    } catch (_) {
      return const <SmartLockHistoryItem>[];
    }
  }

  Future<String> requestUnlock({
    required String marketId,
    required String requestedBy,
    required String customerId,
    required String reason,
  }) {
    return _approvalService.request(
      marketId: marketId,
      requestedBy: requestedBy,
      requestType: 'unlock_customer',
      entityType: 'customer',
      entityId: customerId,
      customerId: customerId,
      reason: reason,
    );
  }
}
