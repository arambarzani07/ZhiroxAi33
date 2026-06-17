import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/customer_service.dart';
import '../../services/debt_service.dart';
import '../../services/smart_lock_query_service.dart';

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
  final _smartLockService = SmartLockQueryService();

  late Future<List<CustomerOption>> _customersFuture;
  CustomerOption? _selectedCustomer;
  bool _saving = false;
  bool _checkingLock = false;
  SmartLockSnapshot? _selectedCustomerLock;

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

  Future<void> _selectCustomer(CustomerOption? value) async {
    final marketId = context.read<AppStateProvider>().marketId;
    setState(() {
      _selectedCustomer = value;
      _selectedCustomerLock = null;
      _checkingLock = value != null;
    });

    if (value == null) return;

    final lock = await _smartLockService.getCustomerLock(
      customerId: value.id,
      marketId: marketId,
    );
    if (!mounted) return;
    setState(() {
      _selectedCustomerLock = lock;
      _checkingLock = false;
    });
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

    final lock = _selectedCustomerLock ??
        await _smartLockService.getCustomerLock(
          customerId: customer.id,
          marketId: marketId,
        );

    if (lock.locked) {
      final approvalId = await _smartLockService.requestUnlock(
        marketId: marketId,
        requestedBy: userId,
        customerId: customer.id,
        reason: 'New debt blocked by Smart Debt Lock. Requested amount: $amount ${_currencyController.text.trim().isEmpty ? 'IQD' : _currencyController.text.trim()}. Lock reason: ${lock.reason}',
      );
      _showMessage('ئەم کڕیارە قفڵکراوە. قەرز تۆمار نەکرا. داواکاری unlock/approval نێردرا. ID: $approvalId');
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

  Widget _lockWarning() {
    final lock = _selectedCustomerLock;
    if (_checkingLock) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
      );
    }
    if (lock == null || !lock.locked) return const SizedBox.shrink();

    return Card(
      color: Colors.red.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.lock, color: Colors.red),
                SizedBox(width: 8),
                Expanded(child: Text('ئەم کڕیارە Smart Debt Lock ـی لەسەرە.')),
              ],
            ),
            if (lock.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('هۆکار: ${lock.reason}'),
            ],
            const SizedBox(height: 8),
            const Text('قەرزی نوێ تۆمار ناکرێت؛ داواکاری unlock/approval بۆ Approval Center دەنێردرێت.'),
          ],
        ),
      ),
    );
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
                  const Text('ئەم کردارە قەرز، ledger entry و audit log دروست دەکات. Smart Lock پێش تۆمارکردن دەپشکنرێت.'),
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
                    onChanged: _saving ? null : _selectCustomer,
                    decoration: const InputDecoration(labelText: 'کڕیار'),
                  ),
                  const SizedBox(height: 14),
                  _lockWarning(),
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
                    onPressed: _saving || _checkingLock ? null : _submit,
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
