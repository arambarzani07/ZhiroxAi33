import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../providers/app_state_provider.dart';
import 'audit_log_screen.dart';

class GuardedAuditLogScreen extends StatelessWidget {
  const GuardedAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canViewAuditLog(role)) {
      return const AccessDeniedView(
        title: 'مێژووی کردار ڕێگەپێنەدراوە',
        message: 'ئەم بەشە تەنها بۆ بەڕێوەبەری مارکێت ڕێگەپێدراوە.',
      );
    }
    return const AuditLogScreen();
  }
}
