import 'pb_client.dart';

class EvidenceItem {
  const EvidenceItem({
    required this.id,
    required this.evidenceType,
    required this.title,
    required this.note,
    required this.relatedEntityType,
    required this.relatedEntityId,
    required this.qualityScore,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String evidenceType;
  final String title;
  final String note;
  final String relatedEntityType;
  final String relatedEntityId;
  final int qualityScore;
  final String createdBy;
  final DateTime? createdAt;
}

class EvidenceService {
  Future<List<EvidenceItem>> listCustomerEvidence({
    required String customerId,
    String? marketId,
  }) async {
    final marketPart = marketId == null || marketId.isEmpty ? '' : ' && market_id = "$marketId"';
    final records = await PBClient.instance.collection('evidence_files').getFullList(
          filter: 'customer_id = "$customerId"$marketPart',
          sort: '-created',
        );

    return records.map((record) {
      final data = record.data;
      return EvidenceItem(
        id: record.id,
        evidenceType: (data['evidence_type'] ?? 'note').toString(),
        title: (data['title'] ?? '').toString(),
        note: (data['note'] ?? '').toString(),
        relatedEntityType: (data['related_entity_type'] ?? '').toString(),
        relatedEntityId: (data['related_entity_id'] ?? '').toString(),
        qualityScore: (data['quality_score'] as num?)?.toInt() ?? 50,
        createdBy: (data['created_by'] ?? '').toString(),
        createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
      );
    }).toList();
  }

  Future<String> createEvidenceNote({
    required String marketId,
    required String customerId,
    required String createdBy,
    required String evidenceType,
    required String title,
    required String note,
    String? relatedEntityType,
    String? relatedEntityId,
    int qualityScore = 60,
  }) async {
    final record = await PBClient.instance.collection('evidence_files').create(body: {
      'market_id': marketId,
      'customer_id': customerId,
      'created_by': createdBy,
      'evidence_type': evidenceType,
      'title': title,
      'note': note,
      'related_entity_type': relatedEntityType ?? 'customer',
      'related_entity_id': relatedEntityId ?? customerId,
      'quality_score': qualityScore.clamp(0, 100),
      'created_at': DateTime.now().toIso8601String(),
    });

    return record.id;
  }
}
