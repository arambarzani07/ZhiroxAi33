import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../providers/app_state_provider.dart';
import 'add_debt_screen.dart';

class GuardedAddDebtScreen extends StatelessWidget {
  const GuardedAddDebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canCreateDebt(role)) {
      return const AccessDeniedView(
        title: 'تۆمارکردنی قەرز ڕێگەپێنەدراوە',
        message: 'ئەم بەشە تەنها بۆ بەڕێوەبەری مارکێت یان کارمەندی ڕێگەپێدراوە.',
      );
    }
    return const AddDebtScreen();
  }
}
