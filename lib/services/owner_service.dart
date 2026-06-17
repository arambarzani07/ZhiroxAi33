import 'pb_client.dart';

class OwnerMarketItem {
  const OwnerMarketItem({
    required this.id,
    required this.name,
    required this.status,
    required this.ownerName,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String status;
  final String ownerName;
  final DateTime? createdAt;
}

class OwnerLicenseItem {
  const OwnerLicenseItem({
    required this.id,
    required this.marketId,
    required this.planName,
    required this.status,
    required this.endsAt,
  });

  final String id;
  final String marketId;
  final String planName;
  final String status;
  final DateTime? endsAt;
}

class OwnerSupportTicketItem {
  const OwnerSupportTicketItem({
    required this.id,
    required this.marketId,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  final String id;
  final String marketId;
  final String title;
  final String status;
  final String priority;
  final DateTime? createdAt;
}

class OwnerPanelSnapshot {
  const OwnerPanelSnapshot({
    required this.markets,
    required this.licenses,
    required this.supportTickets,
    required this.subscriptionPlansCount,
    required this.featureFlagsCount,
  });

  final List<OwnerMarketItem> markets;
  final List<OwnerLicenseItem> licenses;
  final List<OwnerSupportTicketItem> supportTickets;
  final int subscriptionPlansCount;
  final int featureFlagsCount;

  int get activeMarkets => markets.where((item) => item.status == 'active').length;
  int get activeLicenses => licenses.where((item) => item.status == 'active').length;
  int get openTickets => supportTickets.where((item) => item.status != 'closed').length;
}

class OwnerService {
  Future<OwnerPanelSnapshot> loadSnapshot() async {
    final markets = await _safeMarkets();
    final licenses = await _safeLicenses();
    final tickets = await _safeSupportTickets();
    final plansCount = await _safeCount('subscription_plans');
    final flagsCount = await _safeCount('feature_flags');

    return OwnerPanelSnapshot(
      markets: markets,
      licenses: licenses,
      supportTickets: tickets,
      subscriptionPlansCount: plansCount,
      featureFlagsCount: flagsCount,
    );
  }

  Future<List<OwnerMarketItem>> _safeMarkets() async {
    try {
      final records = await PBClient.instance.collection('markets').getFullList(sort: '-created');
      return records.map((record) {
        final data = record.data;
        return OwnerMarketItem(
          id: record.id,
          name: (data['name'] ?? data['market_name'] ?? 'Market').toString(),
          status: (data['status'] ?? 'active').toString(),
          ownerName: (data['owner_name'] ?? '').toString(),
          createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
        );
      }).toList();
    } catch (_) {
      return const <OwnerMarketItem>[];
    }
  }

  Future<List<OwnerLicenseItem>> _safeLicenses() async {
    try {
      final records = await PBClient.instance.collection('licenses').getFullList(sort: '-created');
      return records.map((record) {
        final data = record.data;
        return OwnerLicenseItem(
          id: record.id,
          marketId: (data['market_id'] ?? '').toString(),
          planName: (data['plan_name'] ?? data['plan'] ?? '').toString(),
          status: (data['status'] ?? 'active').toString(),
          endsAt: DateTime.tryParse((data['ends_at'] ?? data['expires_at'] ?? '').toString()),
        );
      }).toList();
    } catch (_) {
      return const <OwnerLicenseItem>[];
    }
  }

  Future<List<OwnerSupportTicketItem>> _safeSupportTickets() async {
    try {
      final records = await PBClient.instance.collection('support_tickets').getFullList(sort: '-created');
      return records.map((record) {
        final data = record.data;
        return OwnerSupportTicketItem(
          id: record.id,
          marketId: (data['market_id'] ?? '').toString(),
          title: (data['title'] ?? '').toString(),
          status: (data['status'] ?? 'open').toString(),
          priority: (data['priority'] ?? 'normal').toString(),
          createdAt: DateTime.tryParse((data['created_at'] ?? data['created'] ?? '').toString()),
        );
      }).toList();
    } catch (_) {
      return const <OwnerSupportTicketItem>[];
    }
  }

  Future<int> _safeCount(String collection) async {
    try {
      final result = await PBClient.instance.collection(collection).getList(page: 1, perPage: 1);
      return result.totalItems;
    } catch (_) {
      return 0;
    }
  }
}
