import 'package:flutter/material.dart';

import '../responsive/screen_breakpoints.dart';

class ResponsiveDashboardGrid extends StatelessWidget {
  const ResponsiveDashboardGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final columns = ScreenBreakpoints.value<int>(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 4,
    );
    final spacing = ScreenBreakpoints.value<double>(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );
    final ratio = ScreenBreakpoints.value<double>(
      context,
      mobile: 1.8,
      tablet: 1.9,
      desktop: 2.2,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: ratio,
      children: children,
    );
  }
}
