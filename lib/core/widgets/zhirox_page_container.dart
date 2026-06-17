import 'package:flutter/material.dart';

import '../responsive/screen_breakpoints.dart';

class ZhiroxPageContainer extends StatelessWidget {
  const ZhiroxPageContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = ScreenBreakpoints.value<EdgeInsets>(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(20),
      desktop: const EdgeInsets.all(28),
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
