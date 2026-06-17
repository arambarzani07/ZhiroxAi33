import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/customer_service.dart';
import '../../services/debt_service.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currencyController = TextEditingController(text: 'IQD');
  final _debtService = DebtService();
  final _customerService = CustomerService();

  late Future<List<CustomerOption>> _customersFuture;
  CustomerOption? _selectedCustomer;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final marketId = context.read<AppStateProvider>().marketId;
    _customersFuture = _customerService.listCustomers(marketId: marketId);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final appState = context.read<AppStateProvider>();
    final marketId = appState.marketId;
    final userId = appState.userId;
    final customer = _selectedCustomer;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '').trim());

    if (marketId == null || marketId.isEmpty || userId == null || userId.isEmpty) {
      _showMessage('هەڵە: market_id یان user_id نەدۆزرایەوە. تکایە دووبارە بچۆ ژوورەوە.');
      return;
    }
    if (customer == null) {
      _showMessage('تکایە کڕیار هەڵبژێرە.');
      return;
    }
    if (amount == null || amount <= 0) {
      _showMessage('تکایە بڕی قەرز بە ژمارەی دروست بنووسە.');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showMessage('تکایە تێبینی/هۆکاری قەرز بنووسە.');
      return;
    }

    setState(() => _saving = true);
    try {
      final debtId = await _debtService.createDebt(
        marketId: marketId,
        customerId: customer.id,
        createdBy: userId,
        amount: amount,
        currentBalance: customer.currentBalance,
        creditLimit: customer.creditLimit,
        overdueCount: customer.overdueCount,
        currency: _currencyController.text.trim().isEmpty ? 'IQD' : _currencyController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;
      _showMessage('قەرزەکە بە سەرکەوتوویی تۆمارکرا. Ledger و Audit ـیش دروستکران. ID: $debtId');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showMessage('هەڵە لە تۆمارکردنی قەرز: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قەرزی نوێ')),
      body: FutureBuilder<List<CustomerOption>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('هەڵە لە خوێندنەوەی کڕیارەکان: ${snapshot.error}'));
          }

          final customers = snapshot.data ?? const <CustomerOption>[];
          return SingleChildScrollView(
            child: ZhiroxPageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تۆمارکردنی قەرزی نوێ',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('ئەم کردارە قەرز، ledger entry و audit log دروست دەکات.'),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<CustomerOption>(
                    value: _selectedCustomer,
                    items: customers
                        .map(
                          (customer) => DropdownMenuItem(
                            value: customer,
                            child: Text(customer.name),
                          ),
                        )
                        .toList(),
                    onChanged: _saving ? null : (value) => setState(() => _selectedCustomer = value),
                    decoration: const InputDecoration(labelText: 'کڕیار'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'بڕی قەرز'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _currencyController,
                    decoration: const InputDecoration(labelText: 'دراو'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'تێبینی / هۆکار'),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_saving ? 'تۆمار دەکرێت...' : 'قەرز تۆمار بکە'),
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
