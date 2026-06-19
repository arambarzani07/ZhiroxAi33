import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../providers/app_state_provider.dart';
import 'approval_center_screen.dart';

class GuardedApprovalCenterScreen extends StatelessWidget {
  const GuardedApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canViewApprovalCenter(role)) {
      return const AccessDeniedView(
        title: 'Approval Center ڕێگەپێنەدراوە',
        message: 'ئەم بەشە تەنها بۆ بەڕێوەبەری مارکێت ڕێگەپێدراوە.',
      );
    }
    return const ApprovalCenterScreen();
  }
}
