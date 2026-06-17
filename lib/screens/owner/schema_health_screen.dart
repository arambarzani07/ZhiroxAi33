import 'package:flutter/material.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../services/schema_health_service.dart';

class SchemaHealthScreen extends StatefulWidget {
  const SchemaHealthScreen({super.key});

  @override
  State<SchemaHealthScreen> createState() => _SchemaHealthScreenState();
}

class _SchemaHealthScreenState extends State<SchemaHealthScreen> {
  final _service = SchemaHealthService();
  late Future<SchemaHealthSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _snapshotFuture = _service.check();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _snapshotFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PocketBase Schema Health')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<SchemaHealthSnapshot>(
          future: _snapshotFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('هەڵە: ${snapshot.error}'))]);
            }

            final data = snapshot.data ?? const SchemaHealthSnapshot(collections: []);
            return ListView(
              children: [
                ZhiroxPageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'PocketBase Schema Health',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('ئەم بەشە collection ـە پێویستەکانی PocketBase دەپشکنێت؛ ئەگەر collection نەبوو، missing دەردەکەوێت.'),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _HealthBadge(title: 'Found', value: data.existingCount.toString(), color: Colors.green),
                          _HealthBadge(title: 'Missing', value: data.missingCount.toString(), color: data.missingCount == 0 ? Colors.green : Colors.red),
                          _HealthBadge(title: 'Total', value: data.collections.length.toString(), color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...data.collections.map((item) => _CollectionStatusCard(item: item)),
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

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _CollectionStatusCard extends StatelessWidget {
  const _CollectionStatusCard({required this.item});

  final SchemaCollectionStatus item;

  @override
  Widget build(BuildContext context) {
    final color = item.exists ? Colors.green : Colors.red;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(item.exists ? Icons.check_circle : Icons.error, color: color),
        title: Text(item.name),
        subtitle: Text(item.exists ? 'records: ${item.totalItems}' : 'missing / inaccessible'),
        trailing: Chip(label: Text(item.exists ? 'OK' : 'Missing')),
      ),
    );
  }
}
