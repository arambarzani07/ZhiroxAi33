import 'package:flutter/material.dart';

class AccessDeniedView extends StatelessWidget {
  const AccessDeniedView({
    super.key,
    this.title = 'دەستڕاگەیشتن ڕێگەپێنەدراوە',
    this.message = 'ئەم بەشە بۆ role ـی ئێستات ڕێگەپێنەدراوە.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 56, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('گەڕانەوە'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
