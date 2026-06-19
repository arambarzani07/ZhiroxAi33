import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

class ZhiroxApp extends StatelessWidget {
  const ZhiroxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.productName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale(AppConfig.defaultLocale),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Consumer<AppStateProvider>(
        builder: (context, state, _) {
          if (state.isBootstrapping) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return state.isLoggedIn ? const DashboardScreen() : const LoginScreen();
        },
      ),
    );
  }
}
