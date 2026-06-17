import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/zhirox_page_container.dart';
import '../../providers/app_state_provider.dart';
import '../../services/customer_service.dart';
import '../../services/evidence_service.dart';

class EvidenceVaultScreen extends StatefulWidget {
  const EvidenceVaultScreen({
    super.key,
    required this.customer,
    required this.marketId,
  });

  final CustomerOption customer;
  final String? marketId;

  @override
  State<EvidenceVaultScreen> createState() => _EvidenceVaultScreenState();
}

class _EvidenceVaultScreenState extends State<EvidenceVaultScreen> {
  final _service = EvidenceService();
  late Future<List<EvidenceItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _itemsFuture = _service.listCustomerEvidence(
      customerId: widget.customer.id,
      marketId: widget.marketId,
    );
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _itemsFuture;
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'بێ بەروار';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'note':
        return 'تێبینی';
      case 'whatsapp':
        return 'WhatsApp';
      case 'sms':
        return 'SMS';
      case 'document':
        return 'Document';
      case 'photo':
        return 'وێنە';
      default:
        return type;
    }
  }

  Future<void> _addEvidence() async {
    final appState = context.read<AppStateProvider>();
    final marketId = widget.marketId ?? appState.marketId;
    final userId = appState.userId;
    if (marketId == null || marketId.isEmpty || userId == null || userId.isEmpty) {
      _showMessage('هەڵە: market_id یان user_id نەدۆزرایەوە.');
      return;
    }

    final result = await showDialog<_EvidenceFormResult>(
      context: context,
      builder: (context) => const _EvidenceFormDialog(),
    );
    if (result == null) return;

    try {
      final id = await _service.createEvidenceNote(
        marketId: marketId,
        customerId: widget.customer.id,
        createdBy: userId,
        evidenceType: result.type,
        title: result.title,
        note: result.note,
        qualityScore: result.qualityScore,
      );
      if (!mounted) return;
      _showMessage('بەڵگە تۆمارکرا. ID: $id');
      setState(_reload);
    } catch (error) {
      if (!mounted) return;
      _showMessage('هەڵە لە تۆمارکردنی بەڵگە: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence Vault')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEvidence,
        icon: const Icon(Icons.add),
        label: const Text('بەڵگە زیاد بکە'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<EvidenceItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('هەڵە: ${snapshot.error}'))]);
            }

            final items = snapshot.data ?? const <EvidenceItem>[];
            return ListView(
              children: [
                ZhiroxPageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Evidence Vault — ${widget.customer.name}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('بەڵگەکان بۆ قەرز، پارەدانەوە، وەسڵ، WhatsApp/SMS و تێبینییەکان لێرە کۆ دەکرێنەوە.'),
                      const SizedBox(height: 18),
                      if (items.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('هێشتا بەڵگەیەک بۆ ئەم کڕیارە نییە.'),
                          ),
                        )
                      else
                        ...items.map(
                          (item) => _EvidenceCard(
                            item: item,
                            typeLabel: _typeLabel(item.evidenceType),
                            dateText: _dateText(item.createdAt),
                          ),
                        ),
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

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.item, required this.typeLabel, required this.dateText});

  final EvidenceItem item;
  final String typeLabel;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    final score = item.qualityScore.clamp(0, 100).toDouble();
    final scoreText = score.toStringAsFixed(0);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.folder_copy),
              const SizedBox(width: 10),
              Expanded(child: Text(item.title.isEmpty ? typeLabel : item.title, style: const TextStyle(fontWeight: FontWeight.bold))),
              Chip(label: Text(typeLabel)),
            ]),
            const SizedBox(height: 8),
            if (item.note.isNotEmpty) SelectableText(item.note),
            const SizedBox(height: 10),
            Text('کات: $dateText'),
            Text('پەیوەست بە: ${item.relatedEntityType} / ${item.relatedEntityId}'),
            const SizedBox(height: 10),
            Text('Evidence Quality: $scoreText/100'),
            LinearProgressIndicator(value: score / 100),
          ],
        ),
      ),
    );
  }
}

class _EvidenceFormDialog extends StatefulWidget {
  const _EvidenceFormDialog();

  @override
  State<_EvidenceFormDialog> createState() => _EvidenceFormDialogState();
}

class _EvidenceFormDialogState extends State<_EvidenceFormDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'note';
  double _quality = 60;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty || _noteController.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      _EvidenceFormResult(
        type: _type,
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        qualityScore: _quality.round(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('بەڵگە زیاد بکە'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'note', child: Text('تێبینی')),
                DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                DropdownMenuItem(value: 'sms', child: Text('SMS')),
                DropdownMenuItem(value: 'document', child: Text('Document')),
                DropdownMenuItem(value: 'photo', child: Text('وێنە')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'note'),
              decoration: const InputDecoration(labelText: 'جۆری بەڵگە'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'ناونیشان')),
            const SizedBox(height: 12),
            TextField(controller: _noteController, minLines: 4, maxLines: 6, decoration: const InputDecoration(labelText: 'ناوەڕۆکی بەڵگە')),
            const SizedBox(height: 12),
            Text('Evidence Quality: ${_quality.round()}/100'),
            Slider(value: _quality, min: 0, max: 100, divisions: 20, onChanged: (value) => setState(() => _quality = value)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('پاشگەزبوونەوە')),
        FilledButton(onPressed: _submit, child: const Text('تۆمارکردن')),
      ],
    );
  }
}

class _EvidenceFormResult {
  const _EvidenceFormResult({required this.type, required this.title, required this.note, required this.qualityScore});

  final String type;
  final String title;
  final String note;
  final int qualityScore;
}
