import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../providers/app_state_provider.dart';
import 'customer_list_screen.dart';

class GuardedCustomerListScreen extends StatelessWidget {
  const GuardedCustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canViewCustomers(role)) {
      return const AccessDeniedView(
        title: 'کڕیارەکان ڕێگەپێنەدراوە',
        message: 'ئەم بەشە تەنها بۆ بەڕێوەبەری مارکێت یان کارمەندی ڕێگەپێدراوە.',
      );
    }
    return const CustomerListScreen();
  }
}
