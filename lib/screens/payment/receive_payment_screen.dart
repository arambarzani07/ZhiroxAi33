import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/customer_service.dart';
import '../../services/debt_query_service.dart';
import '../../services/payment_service.dart';

class ReceivePaymentScreen extends StatefulWidget {
  const ReceivePaymentScreen({super.key});

  @override
  State<ReceivePaymentScreen> createState() => _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customerService = CustomerService();
  final _debtQueryService = DebtQueryService();
  final _paymentService = PaymentService();

  late Future<List<CustomerOption>> _customersFuture;
  Future<List<OpenDebtOption>>? _debtsFuture;
  CustomerOption? _selectedCustomer;
  OpenDebtOption? _selectedDebt;
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
    _noteController.dispose();
    super.dispose();
  }

  void _selectCustomer(CustomerOption? customer) {
    final marketId = context.read<AppStateProvider>().marketId;
    setState(() {
      _selectedCustomer = customer;
      _selectedDebt = null;
      _amountController.clear();
      _debtsFuture = customer == null
          ? null
          : _debtQueryService.listOpenDebtsForCustomer(
              customerId: customer.id,
              marketId: marketId,
            );
    });
  }

  void _selectDebt(OpenDebtOption? debt) {
    setState(() {
      _selectedDebt = debt;
      _amountController.text = debt == null ? '' : debt.remaining.toStringAsFixed(0);
    });
  }

  Future<void> _submit() async {
    final appState = context.read<AppStateProvider>();
    final marketId = appState.marketId;
    final userId = appState.userId;
    final customer = _selectedCustomer;
    final debt = _selectedDebt;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '').trim());

    if (marketId == null || marketId.isEmpty || userId == null || userId.isEmpty) {
      _showMessage('هەڵە: market_id یان user_id نەدۆزرایەوە. تکایە دووبارە بچۆ ژوورەوە.');
      return;
    }
    if (customer == null) {
      _showMessage('تکایە کڕیار هەڵبژێرە.');
      return;
    }
    if (debt == null) {
      _showMessage('تکایە قەرزێکی کراوە هەڵبژێرە.');
      return;
    }
    if (amount == null || amount <= 0) {
      _showMessage('تکایە بڕی پارەدانەوە بە ژمارەی دروست بنووسە.');
      return;
    }
    if (amount > debt.remaining) {
      _showMessage('بڕی پارەدانەوە نابێت لە قەرزی ماوە زیاتر بێت.');
      return;
    }

    setState(() => _saving = true);
    try {
      final paymentId = await _paymentService.receivePayment(
        marketId: marketId,
        customerId: customer.id,
        debtId: debt.id,
        createdBy: userId,
        amount: amount,
        previousBalance: debt.remaining,
        currency: debt.currency,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;
      _showMessage('پارەدانەوە بە سەرکەوتوویی تۆمارکرا. Ledger و Audit ـیش دروستکران. ID: $paymentId');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showMessage('هەڵە لە تۆمارکردنی پارەدانەوە: $error');
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
      appBar: AppBar(title: const Text('وەرگرتنی پارەدانەوە')),
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
                    'تۆمارکردنی پارەدانەوە',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('ئەم کردارە payment، ledger entry، audit log و باقی قەرز نوێ دەکات.'),
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
                  if (_debtsFuture != null)
                    FutureBuilder<List<OpenDebtOption>>(
                      future: _debtsFuture,
                      builder: (context, debtSnapshot) {
                        if (debtSnapshot.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }
                        if (debtSnapshot.hasError) {
                          return Text('هەڵە لە خوێندنەوەی قەرزەکان: ${debtSnapshot.error}');
                        }
                        final debts = debtSnapshot.data ?? const <OpenDebtOption>[];
                        if (debts.isEmpty) {
                          return const Text('ئەم کڕیارە قەرزی کراوەی نییە.');
                        }
                        return DropdownButtonFormField<OpenDebtOption>(
                          value: _selectedDebt,
                          items: debts
                              .map(
                                (debt) => DropdownMenuItem(
                                  value: debt,
                                  child: Text(debt.title),
                                ),
                              )
                              .toList(),
                          onChanged: _saving ? null : _selectDebt,
                          decoration: const InputDecoration(labelText: 'قەرزی کراوە'),
                        );
                      },
                    ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'بڕی پارەدانەوە'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'تێبینی'),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.payments),
                    label: Text(_saving ? 'پارەدانەوە تۆمار دەکرێت...' : 'پارەدانەوە تۆمار بکە'),
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
