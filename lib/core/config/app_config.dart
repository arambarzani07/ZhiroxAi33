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

  static const bool allowDemoData = false;
}
