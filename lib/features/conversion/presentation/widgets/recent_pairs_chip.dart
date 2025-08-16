import 'package:flutter/material.dart';

class RecentPairs extends StatelessWidget {
  final List<String> pairs;
  final ValueChanged<String> onSelect;
  const RecentPairs({super.key, required this.pairs, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (pairs.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final p in pairs)
          InputChip(
            label: Text(p.replaceAll('-', ' → ')),
            avatar: const Icon(Icons.history, size: 18),
            onPressed: () => onSelect(p),
          ),
      ],
    );
  }
}
