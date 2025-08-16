import 'package:flutter/material.dart';

import 'count_up_text.dart';

class ResultCard extends StatelessWidget {
  final num value;
  final num? rate;
  const ResultCard({super.key, required this.value, required this.rate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 1,
        color: Colors.white60,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Converted Amount', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              CountUpText(
                value: value,
                fractionDigits: 4,
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (rate != null)
                Text('Rate: ${rate!.toStringAsFixed(6)}', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
