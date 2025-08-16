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
    final seed = widget.from.codeUnitAt(0) + widget.to.codeUnitAt(0);
    final rnd = math.Random(seed);
    final base = 1 + rnd.nextDouble() * 2;
    _values = List.generate(5, (i) => base + (rnd.nextDouble() - 0.5) * 0.2)..sort();
    _days = List.generate(5, (i) => DateTime.now().subtract(Duration(days: 4 - i)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minV = _values.reduce(math.min);
    final maxV = _values.reduce(math.max);
    final avgV = _values.reduce((a, b) => a + b) / _values.length;

    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '5-Day Trend  ${widget.from} → ${widget.to}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ValueChip(text: 'Min ${minV.toStringAsFixed(4)}', color: Colors.redAccent),
                    const SizedBox(width: 8),
                    _ValueChip(text: 'Avg ${avgV.toStringAsFixed(4)}', color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    _ValueChip(text: 'Max ${maxV.toStringAsFixed(4)}', color: Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.6,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0, left: 6.0, top: 12.0, bottom: 8.0),
                    child: LineChart(
                      _chartData(minV: minV, maxV: maxV, theme: theme),
                      duration: const Duration(milliseconds: 700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LineChartData _chartData({required double minV, required double maxV, required ThemeData theme}) {
    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) {
            final idx = s.spotIndex;
            final d = _days[idx];
            final date = '${d.month}/${d.day}';
            return LineTooltipItem(
              '$date\n${s.y.toStringAsFixed(4)}',
              TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            );
          }).toList(),
        ),
        touchCallback: (event, response) {
          setState(() => _touchedIndex = response?.lineBarSpots?.first.spotIndex);
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: ((maxV - minV) / 4).clamp(0.0001, double.infinity),
        getDrawingHorizontalLine: (_) =>
            FlLine(color: theme.dividerColor.withValues(alpha: 0.2), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: ((maxV - minV) / 4).clamp(0.0001, double.infinity),
            getTitlesWidget: (value, meta) =>
                Text(value.toStringAsFixed(4), style: const TextStyle(fontSize: 10)),
          ),
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
      minY: minV * 0.995,
      maxY: maxV * 1.005,
      minX: 0,
      maxX: (_values.length - 1).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: [for (int i = 0; i < _values.length; i++) FlSpot(i.toDouble(), _values[i])],
          isCurved: true,
          gradient: LinearGradient(colors: [Colors.teal, Colors.blueAccent]),
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.teal.withValues(alpha: 0.3), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, xPercentage, bar, index) {
              final active = _touchedIndex == index;
              return FlDotCirclePainter(
                radius: active ? 5 : 3,
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

class _ValueChip extends StatelessWidget {
  final String text;
  final Color color;
  const _ValueChip({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withValues(alpha: 0.1),
      label: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
