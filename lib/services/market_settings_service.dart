import '../core/config/app_config.dart';
import 'pb_client.dart';

class MarketProfile {
  const MarketProfile({
    required this.id,
    required this.name,
    required this.marketName,
    required this.ownerName,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String name;
  final String marketName;
  final String ownerName;
  final String status;
  final DateTime? createdAt;
}

class MarketSettingsRequest {
  const MarketSettingsRequest({
    required this.name,
    required this.marketName,
    required this.ownerName,
    required this.status,
  });

  final String name;
  final String marketName;
  final String ownerName;
  final String status;
}

class MarketSettingsService {
  Future<MarketProfile> getMarket(String marketId) async {
    if (AppConfig.preDatabaseMode) {
      return const MarketProfile(
        id: AppConfig.preDatabaseMarketId,
        name: 'Demo Market',
        marketName: 'بازاڕی دێمۆ',
        ownerName: 'Aram',
        status: 'active',
      );
    }

    final record = await PBClient.instance.collection('markets').getOne(marketId);
    return _fromRecord(record);
  }

  Future<MarketProfile> updateMarket(String marketId, MarketSettingsRequest request) async {
    if (AppConfig.preDatabaseMode) {
      return MarketProfile(
        id: AppConfig.preDatabaseMarketId,
        name: request.name.trim(),
        marketName: request.marketName.trim(),
        ownerName: request.ownerName.trim(),
        status: request.status,
      );
    }

    final record = await PBClient.instance.collection('markets').update(
      marketId,
      body: {
        'name': request.name.trim(),
        'market_name': request.marketName.trim(),
        'owner_name': request.ownerName.trim(),
        'status': request.status,
      },
    );
    return _fromRecord(record);
  }

  MarketProfile _fromRecord(dynamic record) {
    final data = record.data as Map<String, dynamic>? ?? const {};
    final createdRaw = data['created_at']?.toString();
    return MarketProfile(
      id: record.id.toString(),
      name: (data['name'] ?? '').toString(),
      marketName: (data['market_name'] ?? data['name'] ?? '').toString(),
      ownerName: (data['owner_name'] ?? '').toString(),
      status: (data['status'] ?? 'active').toString(),
      createdAt: createdRaw == null || createdRaw.isEmpty ? null : DateTime.tryParse(createdRaw),
    );
  }
}
