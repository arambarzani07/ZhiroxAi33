import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';
import '../core/enums/system_role.dart';
import '../services/auth_service.dart';

class AppStateProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isBootstrapping = true;
  bool _isLoggedIn = false;
  SystemRole? _role;
  String? _userId;
  String? _marketId;

  bool get isBootstrapping => _isBootstrapping;
  bool get isLoggedIn => _isLoggedIn;
  SystemRole? get role => _role;
  String? get userId => _userId;
  String? get marketId => _marketId;

  Future<void> bootstrap() async {
    _isBootstrapping = true;
    notifyListeners();

    if (AppConfig.preDatabaseMode) {
      _applyPreDatabaseSession();
      _isBootstrapping = false;
      notifyListeners();
      return;
    }

    final session = await _authService.restoreSession();
    _applySession(session);
    _isBootstrapping = false;
    notifyListeners();
  }

  Future<void> login({required String phone, required String password}) async {
    if (AppConfig.preDatabaseMode) {
      _applyPreDatabaseSession();
      notifyListeners();
      return;
    }

    final session = await _authService.login(phone: phone, password: password);
    _applySession(session);
    notifyListeners();
  }

  Future<void> logout() async {
    if (AppConfig.preDatabaseMode) {
      _applyPreDatabaseSession();
      notifyListeners();
      return;
    }

    await _authService.logout();
    _isLoggedIn = false;
    _role = null;
    _userId = null;
    _marketId = null;
    notifyListeners();
  }

  void _applyPreDatabaseSession() {
    _isLoggedIn = true;
    _role = SystemRole.marketManager;
    _userId = AppConfig.preDatabaseUserId;
    _marketId = AppConfig.preDatabaseMarketId;
  }

  void _applySession(AuthSession? session) {
    _isLoggedIn = session != null;
    _role = session?.role;
    _userId = session?.userId;
    _marketId = session?.marketId;
  }
}
