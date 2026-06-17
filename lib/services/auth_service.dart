import '../core/enums/system_role.dart';
import 'pb_client.dart';

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.role,
    required this.marketId,
  });

  final String userId;
  final SystemRole role;
  final String? marketId;
}

class AuthService {
  Future<AuthSession?> restoreSession() async {
    if (!PBClient.isAuthenticated) return null;
    final model = PBClient.instance.authStore.model;
    if (model == null) return null;
    return _sessionFromModel(model);
  }

  Future<AuthSession> login({required String phone, required String password}) async {
    final auth = await PBClient.instance.collection('users').authWithPassword(
          phone.trim(),
          password,
        );
    return _sessionFromModel(auth.record);
  }

  Future<void> logout() async {
    PBClient.clearAuth();
  }

  AuthSession _sessionFromModel(dynamic model) {
    final data = model.data as Map<String, dynamic>? ?? const {};
    final roleText = (data['system_role'] ?? data['role'] ?? 'customer').toString();
    return AuthSession(
      userId: model.id.toString(),
      role: SystemRole.fromString(roleText),
      marketId: data['market_id']?.toString() ?? data['admin_id']?.toString(),
    );
  }
}
