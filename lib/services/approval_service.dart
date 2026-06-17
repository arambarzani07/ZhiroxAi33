import '../core/enums/approval_status.dart';
import 'pb_client.dart';

class ApprovalService {
  Future<String> request({
    required String marketId,
    required String requestedBy,
    required String requestType,
    required String entityType,
    String? entityId,
    String? customerId,
    double? amount,
    String? reason,
  }) async {
    final record = await PBClient.instance.collection('approvals').create(body: {
      'market_id': marketId,
      'requested_by': requestedBy,
      'request_type': requestType,
      'entity_type': entityType,
      'entity_id': entityId,
      'customer_id': customerId,
      'amount': amount ?? 0,
      'reason': reason ?? '',
      'status': ApprovalStatus.pending.storageValue,
      'created_at': DateTime.now().toIso8601String(),
    });
    return record.id;
  }
}
