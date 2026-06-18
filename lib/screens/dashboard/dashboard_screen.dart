import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/security/app_permissions.dart';
import '../../core/widgets/responsive_dashboard_grid.dart';
import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/dashboard_service.dart';
import '../approval/guarded_approval_center_screen.dart';
import '../audit/guarded_audit_log_screen.dart';
import '../customer/guarded_customer_list_screen.dart';
import '../debt/guarded_add_debt_screen.dart';
import '../market/market_settings_screen.dart';
import '../owner/owner_panel_screen.dart';
import '../payment/guarded_receive_payment_screen.dart';

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
    final appState = context.read<AppStateProvider>();
    if (!AppPermissions.canUseMarketWorkspace(appState.role)) {
      _statsFuture = Future.value(DashboardStats.empty());
      return;
    }
    _statsFuture = DashboardService().loadStats(marketId: appState.marketId);
  }

  Future<void> _openAddDebt() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const GuardedAddDebtScreen()));
    if (created == true && mounted) setState(_reloadStats);
  }

  Future<void> _openReceivePayment() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const GuardedReceivePaymentScreen()));
    if (created == true && mounted) setState(_reloadStats);
  }

  Future<void> _openApprovalCenter() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuardedApprovalCenterScreen()));
    if (mounted) setState(_reloadStats);
  }

  Future<void> _openAuditLog() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuardedAuditLogScreen()));
    if (mounted) setState(_reloadStats);
  }

  Future<void> _openCustomers() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuardedCustomerListScreen()));
    if (mounted) setState(_reloadStats);
  }

  Future<void> _openMarketSettings() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MarketSettingsScreen()));
    if (mounted) setState(_reloadStats);
  }

  Future<void> _openOwnerPanel() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerPanelScreen()));
    if (mounted) setState(_reloadStats);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final role = appState.role;
    final canOwner = AppPermissions.canOpenOwnerPanel(role);
    final canMarket = AppPermissions.canUseMarketWorkspace(role);
    final canCreateDebt = AppPermissions.canCreateDebt(role);
    final canReceivePayment = AppPermissions.canReceivePayment(role);
    final canViewCustomers = AppPermissions.canViewCustomers(role);
    final canApproval = AppPermissions.canViewApprovalCenter(role);
    final canAudit = AppPermissions.canViewAuditLog(role);
    final canMarketSettings = AppPermissions.canManageMarketSettings(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.productNameKurdish),
        actions: [
          if (canMarketSettings)
            IconButton(
              tooltip: 'ڕێکخستنەکانی مارکێت',
              onPressed: _openMarketSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          if (canOwner)
            IconButton(
              tooltip: 'SaaS Owner Panel',
              onPressed: _openOwnerPanel,
              icon: const Icon(Icons.admin_panel_settings),
            ),
          IconButton(
            tooltip: 'چوونەدەرەوە',
            onPressed: () => appState.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: canCreateDebt
          ? FloatingActionButton.extended(onPressed: _openAddDebt, icon: const Icon(Icons.add), label: const Text('قەرزی نوێ'))
          : null,
      body: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError && canMarket) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('هەڵە: ${snapshot.error}')));
          }

          final stats = snapshot.data ?? DashboardStats.empty();
          return SingleChildScrollView(
            child: ZhiroxPageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              canOwner ? 'System Owner Control Tower' : 'Credit Control Tower',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(canOwner ? 'بۆ بەڕێوەبردنی SaaS بچۆ Owner Panel.' : 'هەموو ژمارەکان لە PocketBase دەخوێندرێنەوە.'),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (canOwner) FilledButton.icon(onPressed: _openOwnerPanel, icon: const Icon(Icons.admin_panel_settings), label: const Text('Owner Panel')),
                          if (canCreateDebt) FilledButton.icon(onPressed: _openAddDebt, icon: const Icon(Icons.add), label: const Text('قەرزی نوێ')),
                          if (canReceivePayment) FilledButton.icon(onPressed: _openReceivePayment, icon: const Icon(Icons.payments), label: const Text('پارەدانەوە')),
                          if (canViewCustomers) OutlinedButton.icon(onPressed: _openCustomers, icon: const Icon(Icons.people), label: const Text('کڕیارەکان')),
                          if (canMarketSettings) OutlinedButton.icon(onPressed: _openMarketSettings, icon: const Icon(Icons.settings_outlined), label: const Text('ڕێکخستن')),
                          if (canApproval) OutlinedButton.icon(onPressed: _openApprovalCenter, icon: const Icon(Icons.verified_user), label: const Text('پەسندکردن')),
                          if (canAudit) OutlinedButton.icon(onPressed: _openAuditLog, icon: const Icon(Icons.history), label: const Text('مێژووی کردار')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (canMarket)
                    ResponsiveDashboardGrid(
                      children: [
                        _StatCard(title: 'کۆی قەرز', value: stats.totalDebtText, icon: Icons.account_balance_wallet),
                        _StatCard(title: 'قەرزی ماوە', value: stats.remainingDebtText, icon: Icons.warning_amber),
                        _StatCard(title: 'پارەدانەوەکان', value: stats.totalPaymentsText, icon: Icons.payments),
                        _StatCard(title: 'کڕیارەکان', value: stats.totalCustomers.toString(), icon: Icons.people),
                      ],
                    )
                  else
                    const _RoleNoticeCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleNoticeCard extends StatelessWidget {
  const _RoleNoticeCard();

  @override
  Widget build(BuildContext context) {
    return const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('بەشی ئێستات بەپێی role سنووردارکراوە.')));
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
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
