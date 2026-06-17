import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/customer_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کڕیارەکان')),
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
              return customer.name.toLowerCase().contains(_query.toLowerCase().trim());
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
                      const SizedBox(height: 18),
                      TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'گەڕان بە ناوی کڕیار',
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
  const _CustomerCard({required this.customer, required this.onTap});

  final CustomerOption customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(customer.name.isEmpty ? '?' : customer.name.characters.first),
        ),
        title: Text(customer.name),
        subtitle: Text('قەرزی ئێستا: ${customer.currentBalance.toStringAsFixed(0)} — سنوور: ${customer.creditLimit.toStringAsFixed(0)}'),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}
