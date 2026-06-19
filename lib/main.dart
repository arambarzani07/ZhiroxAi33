import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/zhirox_app.dart';
import 'core/config/app_config.dart';
import 'providers/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppStateProvider()..bootstrap(),
        ),
      ],
      child: const ZhiroxApp(),
    ),
  );
}

class AppBootstrapInfo {
  const AppBootstrapInfo._();

  static String get productName => AppConfig.productName;
}
