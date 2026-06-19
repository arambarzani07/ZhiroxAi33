import 'dart:convert';

import 'pb_client.dart';

class AuditLogItem {
  const AuditLogItem({
    required this.id,
    required this.actorUserId,
    required this.actionType,
    required this.entityType,
    required this.entityId,
    required this.reason,
    required this.beforeValueText,
    required this.afterValueText,
    required this.createdAt,
  });

  final String id;
  final String actorUserId;
  final String actionType;
  final String entityType;
  final String entityId;
  final String reason;
  final String beforeValueText;
  final String afterValueText;
  final DateTime? createdAt;
}

class AuditQueryService {
  Future<List<AuditLogItem>> listRecent({
    String? marketId,
    int perPage = 50,
  }) async {
    final filter = marketId == null || marketId.isEmpty ? '' : 'market_id = "$marketId"';
    final records = await PBClient.instance.collection('audit_logs').getList(
          page: 1,
          perPage: perPage,
          filter: filter,
          sort: '-created',
        );

    return records.items.map((record) {
      final data = record.data;
      return AuditLogItem(
        id: record.id,
        actorUserId: (data['actor_user_id'] ?? '').toString(),
        actionType: (data['action_type'] ?? '').toString(),
        entityType: (data['entity_type'] ?? '').toString(),
        entityId: (data['entity_id'] ?? '').toString(),
        reason: (data['reason'] ?? '').toString(),
        beforeValueText: _jsonText(data['before_value']),
        afterValueText: _jsonText(data['after_value']),
        createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
      );
    }).toList();
  }

  static String _jsonText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
