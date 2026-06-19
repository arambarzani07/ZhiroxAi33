import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/customer_service.dart';
import 'customer_form_screen.dart';
import 'customer_profile_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _customerService = CustomerService();
  late Future<List<CustomerOption>> _customersFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final marketId = context.read<AppStateProvider>().marketId;
    _customersFuture = _customerService.listCustomers(marketId: marketId);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _customersFuture;
  }

  void _openProfile(CustomerOption customer) {
    final marketId = context.read<AppStateProvider>().marketId;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerProfileScreen(
          customer: customer,
          marketId: marketId,
        ),
      ),
    );
  }

  Future<void> _openCustomerForm({CustomerOption? customer}) async {
    final saved = await Navigator.of(context).push<CustomerOption>(
      MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)),
    );
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(customer == null ? 'کڕیار زیادکرا: ${saved.name}' : 'کڕیار نوێکرایەوە: ${saved.name}')),
      );
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canViewCustomers(role)) {
      return const AccessDeniedView(
        title: 'دەستڕاگەیشتن ڕێگەپێنەدراوە',
        message: 'تەنها بەڕێوەبەر یان کارمەندی ڕێگەپێدراو دەتوانێت لیستی کڕیارەکان ببینێت.',
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('کڕیارەکان')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCustomerForm(),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('کڕیاری نوێ'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<CustomerOption>>(
          future: _customersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('هەڵە لە خوێندنەوەی کڕیارەکان: ${snapshot.error}'),
                  ),
                ],
              );
            }

            final allCustomers = snapshot.data ?? const <CustomerOption>[];
            final customers = allCustomers.where((customer) {
              if (_query.trim().isEmpty) return true;
              final normalizedQuery = _query.toLowerCase().trim();
              return customer.name.toLowerCase().contains(normalizedQuery) || (customer.phone ?? '').contains(normalizedQuery);
            }).toList();

            return ListView(
              children: [
                ZhiroxPageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'کڕیارەکان و Customer Debt Passport',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('کڕیار هەڵبژێرە بۆ بینینی پڕۆفایل، قەرز، پارەدانەوە و ledger timeline.'),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => _openCustomerForm(),
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label: const Text('زیادکردنی کڕیار'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'گەڕان بە ناو یان ژمارەی مۆبایل',
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (customers.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('هیچ کڕیارێک نەدۆزرایەوە.'),
                          ),
                        )
                      else
                        ...customers.map((customer) => _CustomerCard(
                              customer: customer,
                              onTap: () => _openProfile(customer),
                              onEdit: () => _openCustomerForm(customer: customer),
                            )),
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

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.onTap, required this.onEdit});

  final CustomerOption customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(_initial(customer.name))),
        title: Text(customer.name),
        subtitle: Text(
          'مۆبایل: ${customer.phone ?? '—'}\nقەرزی ئێستا: ${customer.currentBalance.toStringAsFixed(0)} — سنوور: ${customer.creditLimit.toStringAsFixed(0)}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'دەستکاری',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }
}
