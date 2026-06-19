class AppConfig {
  const AppConfig._();

  static const String productName = 'Zhirox AI Debt';
  static const String productNameKurdish = 'ژیرۆکس ئەی ئای قەرز';
  static const String productSubtitleKurdish = 'سیستەمی ژیری پاراستنی قەرز و پارەی مارکێت';

  static const String defaultLocale = 'ckb';
  static const String defaultCurrency = 'IQD';

  static const String pocketBaseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'https://pocketbase-production-18bc.up.railway.app',
  );

  /// Temporary mode for UI/feature completion before the real PocketBase
  /// database/users/API rules are fully configured.
  ///
  /// Set `--dart-define=PRE_DATABASE_MODE=false` for production login flow.
  static const bool preDatabaseMode = bool.fromEnvironment(
    'PRE_DATABASE_MODE',
    defaultValue: true,
  );

  static const bool allowDemoData = preDatabaseMode;

  static const String preDatabaseUserId = 'pre_database_manager';
  static const String preDatabaseMarketId = 'pre_database_market';
}
