import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendSheet extends StatefulWidget {
  final String from;
  final String to;
  const TrendSheet({super.key, required this.from, required this.to});

  @override
  State<TrendSheet> createState() => _TrendSheetState();
}

class _TrendSheetState extends State<TrendSheet> {
  late final List<double> _values;
  late final List<DateTime> _days;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    // Mock values for 5 days, deterministic from pair
    final seed = widget.from.codeUnitAt(0) + widget.to.codeUnitAt(0);
    final rnd = math.Random(seed);
    final base = 1 + rnd.nextDouble() * 2; // between 1 and 3
    _values = List.generate(5, (i) => base + (rnd.nextDouble() - 0.5) * 0.2)..sort();
    _days = List.generate(5, (i) => DateTime.now().subtract(Duration(days: 4 - i)));
  }

  @override
  Widget build(BuildContext context) {
    final minV = _values.reduce(math.min);
    final maxV = _values.reduce(math.max);
    final avgV = _values.reduce((a, b) => a + b) / _values.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('5-Day Trend  ${widget.from} → ${widget.to}', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Chip(text: 'Min ${minV.toStringAsFixed(4)}'),
                const SizedBox(width: 8),
                _Chip(text: 'Avg ${avgV.toStringAsFixed(4)}'),
                const SizedBox(width: 8),
                _Chip(text: 'Max ${maxV.toStringAsFixed(4)}'),
              ],
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.6,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 6.0, top: 12.0, bottom: 8.0),
                child: LineChart(
                  _chartData(minV: minV, maxV: maxV),
                  duration: const Duration(milliseconds: 700), // animated draw
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _chartData({required double minV, required double maxV}) {
    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) {
            final idx = s.spotIndex;
            final d = _days[idx];
            final date = '${d.month}/${d.day}';
            return LineTooltipItem('$date\n${s.y.toStringAsFixed(4)}', const TextStyle(fontWeight: FontWeight.bold));
          }).toList(),
        ),
        touchCallback: (event, response) {
          setState(() => _touchedIndex = response?.lineBarSpots?.first.spotIndex);
        },
      ),
      gridData: FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 44, interval: ((maxV - minV) / 4).clamp(0.0001, double.infinity)),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= _days.length) return const SizedBox.shrink();
              final d = _days[idx];
              return Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text('${d.month}/${d.day}', style: const TextStyle(fontSize: 11)),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      minY: (minV * 0.995),
      maxY: (maxV * 1.005),
      minX: 0,
      maxX: (_values.length - 1).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < _values.length; i++) FlSpot(i.toDouble(), _values[i]),
          ],
          isCurved: true,
          color: Colors.teal,
          barWidth: 3,
          belowBarData: BarAreaData(show: true, color: Colors.teal.withValues(alpha: 0.15)),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, xPercentage, bar, index) {
              final active = _touchedIndex == index;
              return FlDotCirclePainter(
                radius: active ? 3.5 : 2.5,
                color: active ? Colors.orange : Colors.teal,
                strokeWidth: 0,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});
  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: const Offset(0, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1,
        child: Chip(label: Text(text)),
      ),
    );
  }
}
