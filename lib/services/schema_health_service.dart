import 'pb_client.dart';

class SchemaCollectionStatus {
  const SchemaCollectionStatus({
    required this.name,
    required this.exists,
    required this.totalItems,
    required this.error,
  });

  final String name;
  final bool exists;
  final int totalItems;
  final String? error;
}

class SchemaHealthSnapshot {
  const SchemaHealthSnapshot({required this.collections});

  final List<SchemaCollectionStatus> collections;

  int get existingCount => collections.where((item) => item.exists).length;
  int get missingCount => collections.where((item) => !item.exists).length;
  bool get healthy => missingCount == 0;
}

class SchemaHealthService {
  static const requiredCollections = <String>[
    'users',
    'markets',
    'debts',
    'payments',
    'notifications',
    'audit_logs',
    'debt_ledger_entries',
    'approvals',
    'receipts',
    'customer_scores',
    'smart_locks',
    'lock_history',
    'evidence_files',
    'dispute_cases',
    'subscription_plans',
    'licenses',
    'support_tickets',
    'feature_flags',
  ];

  Future<SchemaHealthSnapshot> check() async {
    final statuses = <SchemaCollectionStatus>[];

    for (final name in requiredCollections) {
      try {
        final result = await PBClient.instance.collection(name).getList(page: 1, perPage: 1);
        statuses.add(SchemaCollectionStatus(
          name: name,
          exists: true,
          totalItems: result.totalItems,
          error: null,
        ));
      } catch (error) {
        statuses.add(SchemaCollectionStatus(
          name: name,
          exists: false,
          totalItems: 0,
          error: error.toString(),
        ));
      }
    }

    return SchemaHealthSnapshot(collections: statuses);
  }
}
