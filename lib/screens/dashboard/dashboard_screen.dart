import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/responsive_dashboard_grid.dart';
import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/dashboard_service.dart';
import '../debt/add_debt_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _reloadStats();
  }

  void _reloadStats() {
    final marketId = context.read<AppStateProvider>().marketId;
    _statsFuture = DashboardService().loadStats(marketId: marketId);
  }

  Future<void> _openAddDebt() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddDebtScreen()),
    );
    if (created == true && mounted) {
      setState(_reloadStats);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.productNameKurdish),
        actions: [
          IconButton(
            tooltip: 'چوونەدەرەوە',
            onPressed: () => appState.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDebt,
        icon: const Icon(Icons.add),
        label: const Text('قەرزی نوێ'),
      ),
      body: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('هەڵە لە خوێندنەوەی داتای ڕاستەقینە: ${snapshot.error}'),
              ),
            );
          }

          final stats = snapshot.data ?? DashboardStats.empty();
          return SingleChildScrollView(
            child: ZhiroxPageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Credit Control Tower',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text('هەموو ژمارەکان لە PocketBase ـی ڕاستەقینە دەخوێندرێنەوە.'),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _openAddDebt,
                        icon: const Icon(Icons.add),
                        label: const Text('قەرزی نوێ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ResponsiveDashboardGrid(
                    children: [
                      _StatCard(title: 'کۆی قەرز', value: stats.totalDebtText, icon: Icons.account_balance_wallet),
                      _StatCard(title: 'قەرزی ماوە', value: stats.remainingDebtText, icon: Icons.warning_amber),
                      _StatCard(title: 'پارەدانەوەکان', value: stats.totalPaymentsText, icon: Icons.payments),
                      _StatCard(title: 'کڕیارەکان', value: stats.totalCustomers.toString(), icon: Icons.people),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
