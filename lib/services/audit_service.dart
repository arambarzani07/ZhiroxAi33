import 'pb_client.dart';

class AuditService {
  Future<void> log({
    required String marketId,
    required String actorUserId,
    required String actionType,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? beforeValue,
    Map<String, dynamic>? afterValue,
    String? reason,
  }) async {
    await PBClient.instance.collection('audit_logs').create(body: {
      'market_id': marketId,
      'actor_user_id': actorUserId,
      'action_type': actionType,
      'entity_type': entityType,
      'entity_id': entityId,
      'before_value': beforeValue ?? {},
      'after_value': afterValue ?? {},
      'reason': reason ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
