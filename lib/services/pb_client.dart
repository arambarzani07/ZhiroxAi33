import 'package:pocketbase/pocketbase.dart';

import '../core/config/app_config.dart';

class PBClient {
  PBClient._();

  static final PocketBase instance = PocketBase(AppConfig.pocketBaseUrl);

  static bool get isAuthenticated => instance.authStore.isValid;
  static String? get currentUserId => instance.authStore.model?.id;

  static void clearAuth() => instance.authStore.clear();
}
