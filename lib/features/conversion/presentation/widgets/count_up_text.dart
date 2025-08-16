import 'package:flutter/material.dart';

class CountUpText extends StatelessWidget {
  final num value;
  final Duration duration;
  final TextStyle? style;
  final int fractionDigits;

  const CountUpText({super.key, required this.value, this.duration = const Duration(milliseconds: 800), this.style, this.fractionDigits = 2});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      builder: (context, v, _) => Text(v.toStringAsFixed(fractionDigits), style: style),
    );
  }
}
