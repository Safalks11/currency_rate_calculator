import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/currencies.dart';

class CurrencyPickerSheet extends StatefulWidget {
  final String? selectedCode;
  const CurrencyPickerSheet({super.key, this.selectedCode});

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = kCurrencies
        .where((c) =>
            c.code.toLowerCase().contains(_query.toLowerCase()) ||
            c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.selectedCode != null)
                  Hero(
                    tag: 'currency-${widget.selectedCode}',
                    child: Chip(
                      label: Text(widget.selectedCode!),
                    ),
                  ),
                const SizedBox(width: 8),
                Text('Select Currency', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search currency or code'),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final c = items[index];
                  final selected = c.code == widget.selectedCode;
                  return ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 20)),
                    title: AutoSizeText('${c.code} — ${c.name}', maxLines: 1),
                    trailing: selected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
                    onTap: () => Navigator.of(context).pop(c.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
