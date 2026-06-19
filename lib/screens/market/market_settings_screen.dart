import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security/app_permissions.dart';
import '../../core/widgets/access_denied_view.dart';
import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/market_settings_service.dart';

class MarketSettingsScreen extends StatefulWidget {
  const MarketSettingsScreen({super.key});

  @override
  State<MarketSettingsScreen> createState() => _MarketSettingsScreenState();
}

class _MarketSettingsScreenState extends State<MarketSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MarketSettingsService();
  final _nameController = TextEditingController();
  final _marketNameController = TextEditingController();
  final _ownerNameController = TextEditingController();

  late Future<MarketProfile> _profileFuture;
  String _status = 'active';
  bool _isSaving = false;
  bool _formFilled = false;

  static const List<String> _statusOptions = ['active', 'trial', 'expired', 'suspended', 'disabled'];

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _marketNameController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  Future<MarketProfile> _loadProfile() async {
    final marketId = context.read<AppStateProvider>().marketId;
    if (marketId == null || marketId.isEmpty) {
      throw StateError('market_id نەدۆزرایەوە.');
    }
    return _service.getMarket(marketId);
  }

  void _fillForm(MarketProfile profile) {
    if (_formFilled) return;
    _nameController.text = profile.name;
    _marketNameController.text = profile.marketName;
    _ownerNameController.text = profile.ownerName;
    _status = _statusOptions.contains(profile.status) ? profile.status : 'active';
    _formFilled = true;
  }

  Future<void> _save() async {
    final marketId = context.read<AppStateProvider>().marketId;
    if (marketId == null || marketId.isEmpty) {
      _showMessage('market_id نەدۆزرایەوە.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updated = await _service.updateMarket(
        marketId,
        MarketSettingsRequest(
          name: _nameController.text,
          marketName: _marketNameController.text,
          ownerName: _ownerNameController.text,
          status: _status,
        ),
      );
      if (!mounted) return;
      setState(() {
        _formFilled = false;
        _profileFuture = Future.value(updated);
      });
      _showMessage('ڕێکخستنەکانی مارکێت پاشەکەوت کران.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('هەڵە لە پاشەکەوتکردن: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'ئەم خانەیە پێویستە';
    return null;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'چالاک';
      case 'trial':
        return 'تاقیکردنەوە';
      case 'expired':
        return 'بەسەرچوو';
      case 'suspended':
        return 'ڕاگیراو';
      case 'disabled':
        return 'ناچالاک';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStateProvider>().role;
    if (!AppPermissions.canManageMarketSettings(role)) {
      return const AccessDeniedView(
        title: 'دەستڕاگەیشتن ڕێگەپێنەدراوە',
        message: 'تەنها بەڕێوەبەری مارکێت دەتوانێت ڕێکخستنەکانی مارکێت بگۆڕێت.',
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ڕێکخستنەکانی مارکێت')),
      body: FutureBuilder<MarketProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('هەڵە لە خوێندنەوەی مارکێت: ${snapshot.error}'),
              ),
            );
          }

          final profile = snapshot.data!;
          _fillForm(profile);

          return ListView(
            children: [
              ZhiroxPageContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'پڕۆفایلی مارکێت',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('ناو و زانیارییە بنەڕەتییەکانی مارکێت لێرە ڕێک بخە. ئەم زانیاریانە لە داشبۆرد، ڕاپۆرت و داهاتوودا لە وەسڵەکاندا بەکاردێن.'),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nameController,
                        validator: _required,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'ناوی سیستەمی مارکێت',
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _marketNameController,
                        validator: _required,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'ناوی بازرگانی/پیشاندان',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ownerNameController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'ناوی خاوەن/بەڕێوەبەر',
                          prefixIcon: Icon(Icons.manage_accounts_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'دۆخی مارکێت',
                          prefixIcon: Icon(Icons.verified_outlined),
                        ),
                        items: _statusOptions
                            .map((status) => DropdownMenuItem(value: status, child: Text(_statusLabel(status))))
                            .toList(),
                        onChanged: (value) => setState(() => _status = value ?? 'active'),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ناسنامەی مارکێت', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('ID: ${profile.id}'),
                              if (profile.createdAt != null) Text('دروستکراوە: ${profile.createdAt!.toIso8601String()}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'پاشەکەوت دەکرێت...' : 'پاشەکەوتکردنی ڕێکخستن'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
