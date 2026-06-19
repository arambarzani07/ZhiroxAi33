import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../core/widgets/responsive_dashboard_grid.dart';
import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/owner_service.dart';
import 'schema_health_screen.dart';

class OwnerPanelScreen extends StatefulWidget {
  const OwnerPanelScreen({super.key});

  @override
  State<OwnerPanelScreen> createState() => _OwnerPanelScreenState();
}

class _OwnerPanelScreenState extends State<OwnerPanelScreen> {
  final _service = OwnerService();
  late Future<OwnerPanelSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _snapshotFuture = _service.loadSnapshot();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _snapshotFuture;
  }

  void _openSchemaHealth() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SchemaHealthScreen()),
    );
  }

  String _dateText(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canOpenOwnerPanel(role)) {
      return const AccessDeniedView(
        title: 'Owner Panel ڕێگەپێنەدراوە',
        message: 'ئەم بەشە تەنها بۆ system_owner ـە. خاوەنی مارکێت و کارمەند نابێت ئەم بەشە ببینن.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SaaS Owner Panel'),
        actions: [
          IconButton(
            tooltip: 'Schema Health',
            onPressed: _openSchemaHealth,
            icon: const Icon(Icons.schema),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<OwnerPanelSnapshot>(
          future: _snapshotFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('هەڵە: ${snapshot.error}'))]);
            }

            final data = snapshot.data ?? const OwnerPanelSnapshot(
              markets: [],
              licenses: [],
              supportTickets: [],
              subscriptionPlansCount: 0,
              featureFlagsCount: 0,
            );

            return ListView(
              children: [
                ZhiroxPageContainer(
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
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'System Owner Control Tower',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text('ئەم بەشە تەنها بۆ خاوەنی سیستەمە؛ داتای تایبەتی قەرز/کڕیار/پارەدانەوەی مارکێتەکان ناخوێنێتەوە.'),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _openSchemaHealth,
                            icon: const Icon(Icons.schema),
                            label: const Text('Schema Health'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ResponsiveDashboardGrid(
                        children: [
                          _OwnerStatCard(title: 'Markets', value: data.markets.length.toString(), icon: Icons.store),
                          _OwnerStatCard(title: 'Active Licenses', value: data.activeLicenses.toString(), icon: Icons.verified),
                          _OwnerStatCard(title: 'Open Tickets', value: data.openTickets.toString(), icon: Icons.support_agent),
                          _OwnerStatCard(title: 'Feature Flags', value: data.featureFlagsCount.toString(), icon: Icons.flag),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Markets'),
                      _MarketsTable(markets: data.markets, dateText: _dateText),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Licenses'),
                      _LicensesTable(licenses: data.licenses, dateText: _dateText),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Support Tickets'),
                      _TicketsTable(tickets: data.supportTickets, dateText: _dateText),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OwnerStatCard extends StatelessWidget {
  const _OwnerStatCard({required this.title, required this.value, required this.icon});

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
            const SizedBox(height: 12),
            Text(title),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _MarketsTable extends StatelessWidget {
  const _MarketsTable({required this.markets, required this.dateText});

  final List<OwnerMarketItem> markets;
  final String Function(DateTime?) dateText;

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const _EmptyCard(text: 'هیچ market ـێک نەدۆزرایەوە.');
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Market')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Owner')),
            DataColumn(label: Text('Created')),
          ],
          rows: markets.map((market) => DataRow(cells: [
                DataCell(Text(market.name)),
                DataCell(Text(market.status)),
                DataCell(Text(market.ownerName.isEmpty ? '-' : market.ownerName)),
                DataCell(Text(dateText(market.createdAt))),
              ])).toList(),
        ),
      ),
    );
  }
}

class _LicensesTable extends StatelessWidget {
  const _LicensesTable({required this.licenses, required this.dateText});

  final List<OwnerLicenseItem> licenses;
  final String Function(DateTime?) dateText;

  @override
  Widget build(BuildContext context) {
    if (licenses.isEmpty) return const _EmptyCard(text: 'هیچ license ـێک نەدۆزرایەوە.');
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Market ID')),
            DataColumn(label: Text('Plan')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Ends')),
          ],
          rows: licenses.map((license) => DataRow(cells: [
                DataCell(Text(license.marketId)),
                DataCell(Text(license.planName.isEmpty ? '-' : license.planName)),
                DataCell(Text(license.status)),
                DataCell(Text(dateText(license.endsAt))),
              ])).toList(),
        ),
      ),
    );
  }
}

class _TicketsTable extends StatelessWidget {
  const _TicketsTable({required this.tickets, required this.dateText});

  final List<OwnerSupportTicketItem> tickets;
  final String Function(DateTime?) dateText;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return const _EmptyCard(text: 'هیچ support ticket ـێک نییە.');
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Market')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Created')),
          ],
          rows: tickets.map((ticket) => DataRow(cells: [
                DataCell(Text(ticket.title.isEmpty ? '-' : ticket.title)),
                DataCell(Text(ticket.marketId)),
                DataCell(Text(ticket.priority)),
                DataCell(Text(ticket.status)),
                DataCell(Text(dateText(ticket.createdAt))),
              ])).toList(),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text),
      ),
    );
  }
}
