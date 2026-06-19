import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/customer_service.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key, this.customer});

  final CustomerOption? customer;

  bool get isEditing => customer != null;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CustomerService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _currentBalanceController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _portalEnabled = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    if (customer != null) {
      _nameController.text = customer.name;
      _phoneController.text = customer.phone ?? '';
      _creditLimitController.text = customer.creditLimit.toStringAsFixed(0);
      _currentBalanceController.text = customer.currentBalance.toStringAsFixed(0);
      _portalEnabled = customer.portalEnabled;
    } else {
      _creditLimitController.text = '0';
      _currentBalanceController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _creditLimitController.dispose();
    _currentBalanceController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final appState = context.read<AppStateProvider>();
    final marketId = appState.marketId;
    if (marketId == null || marketId.isEmpty) {
      _showMessage('market_id نەدۆزرایەوە. تکایە بە هەژماری مارکێت بچۆ ژوورەوە.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final request = CustomerUpsertRequest(
        name: _nameController.text,
        phone: _phoneController.text,
        marketId: marketId,
        creditLimit: _parseAmount(_creditLimitController.text),
        currentBalance: _parseAmount(_currentBalanceController.text),
        portalEnabled: _portalEnabled,
        password: _passwordController.text,
      );

      final savedCustomer = widget.isEditing
          ? await _service.updateCustomer(widget.customer!.id, request)
          : await _service.createCustomer(request);

      if (!mounted) return;
      Navigator.of(context).pop(savedCustomer);
    } catch (error) {
      if (!mounted) return;
      _showMessage('هەڵە لە پاشەکەوتکردنی کڕیار: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  double _parseAmount(String value) {
    final normalized = value.replaceAll(',', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'ئەم خانەیە پێویستە';
    return null;
  }

  String? _phoneValidator(String? value) {
    final base = _requiredText(value);
    if (base != null) return base;
    if (value!.trim().length < 7) return 'ژمارەی مۆبایل زۆر کورتە';
    return null;
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'بڕێک بنووسە';
    if (_parseAmount(value) < 0) return 'بڕ نابێت نەرێنی بێت';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (widget.isEditing && (value == null || value.trim().isEmpty)) return null;
    if (value == null || value.trim().length < 8) return 'وشەی نهێنی لانیکەم ٨ پیت بێت';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canViewCustomers(role)) {
      return const AccessDeniedView(
        title: 'دەستڕاگەیشتن ڕێگەپێنەدراوە',
        message: 'تەنها بەڕێوەبەر یان کارمەندی ڕێگەپێدراو دەتوانێت کڕیار زیاد بکات یان دەستکاری بکات.',
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'دەستکاری کڕیار' : 'زیادکردنی کڕیار')),
      body: ListView(
        children: [
          ZhiroxPageContainer(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.isEditing ? 'زانیارییەکانی کڕیار نوێ بکەوە' : 'کڕیارێکی نوێ زیاد بکە',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('کڕیارەکان بە market_id ـی مارکێتی ئێستات دەبەسترێنەوە بۆ پاراستنی داتا.'),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    validator: _requiredText,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'ناوی کڕیار',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    validator: _phoneValidator,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'ژمارەی مۆبایل',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _creditLimitController,
                    validator: _amountValidator,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'سنووری قەرز',
                      prefixIcon: Icon(Icons.credit_score_outlined),
                      suffixText: 'IQD',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _currentBalanceController,
                    validator: _amountValidator,
                    enabled: !widget.isEditing,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'قەرزی دەستپێک',
                      helperText: 'لە دەستکاری کڕیاردا balance بە ledger/payment دەگۆڕدرێت، نەک لێرە.',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      suffixText: 'IQD',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('پۆرتاڵی کڕیار چالاک بێت'),
                    subtitle: const Text('ئەگەر چالاک بێت، کڕیار دواتر دەتوانێت وەسڵ و balance ـی خۆی ببینێت.'),
                    value: _portalEnabled,
                    onChanged: (value) => setState(() => _portalEnabled = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    validator: _passwordValidator,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: widget.isEditing ? 'وشەی نهێنی نوێ (ئارەزوومەندانە)' : 'وشەی نهێنی کاتی',
                      prefixIcon: const Icon(Icons.lock_outline),
                      helperText: widget.isEditing ? 'بەتاڵی بهێڵە بۆ ئەوەی نەگۆڕدرێت.' : 'لانیکەم ٨ پیت. دواتر دەتوانرێت بگۆڕدرێت.',
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'پاشەکەوت دەکرێت...' : 'پاشەکەوتکردن'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
