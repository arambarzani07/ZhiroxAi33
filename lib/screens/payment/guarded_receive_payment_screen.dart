import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../providers/app_state_provider.dart';
import 'receive_payment_screen.dart';

class GuardedReceivePaymentScreen extends StatelessWidget {
  const GuardedReceivePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canReceivePayment(role)) {
      return const AccessDeniedView(
        title: 'وەرگرتنی پارە ڕێگەپێنەدراوە',
        message: 'ئەم بەشە تەنها بۆ بەڕێوەبەری مارکێت یان کارمەندی ڕێگەپێدراوە.',
      );
    }
    return const ReceivePaymentScreen();
  }
}
