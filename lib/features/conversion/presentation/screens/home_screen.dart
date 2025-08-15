import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/currencies.dart';
import '../../presentation/cubit/conversion_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../widgets/amount_input_formatter.dart';
import '../../widgets/animated_convert_button.dart';
import '../../widgets/count_up_text.dart';
import '../../widgets/currency_picker_sheet.dart';
import '../../widgets/result_error.dart';
import '../../widgets/result_skeleton.dart';
import '../../widgets/trend_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _RecentPairs extends StatelessWidget {
  final List<String> pairs;
  final ValueChanged<String> onSelect;
  const _RecentPairs({required this.pairs, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (pairs.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final p in pairs)
            ActionChip(label: Text(p.replaceAll('-', ' → ')), onPressed: () => onSelect(p)),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _from = 'USD';
  String _to = 'INR';
  final _amount = TextEditingController(text: '1');
  double _swapTurns = 0;
  final List<String> _recentPairs = [];
  late final AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _bounceCtrl.reverse();
      });
  }

  @override
  void dispose() {
    _amount.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
      _swapTurns += 1;
      _rememberPair();
    });
  }

  Future<void> _pickCurrency({required bool pickingFrom}) async {
    final current = pickingFrom ? _from : _to;
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CurrencyPickerSheet(selectedCode: current),
    );
    if (code != null && code.isNotEmpty) {
      setState(() {
        if (pickingFrom) {
          _from = code;
        } else {
          _to = code;
        }
        _rememberPair();
      });
    }
  }

  void _rememberPair() {
    final pair = '$_from-$_to';
    _recentPairs.remove(pair);
    _recentPairs.insert(0, pair);
    if (_recentPairs.length > 6) _recentPairs.removeLast();
  }

  void _convert() {
    final val = double.tryParse(_amount.text.replaceAll(',', ''));
    if (val == null || val <= 0) {
      _bounceCtrl.forward(from: 0);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    context.read<ConversionCubit>().convert(_from, _to, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickCurrency(pickingFrom: true),
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'From'),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'currency-$_from',
                            child: CircleAvatar(
                              child: Text(currencyByCode(_from)?.flag ?? _from.substring(0, 1)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoSizeText(
                              '$_from — ${currencyByCode(_from)?.name ?? ''}',
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _swapTurns,
                  duration: const Duration(milliseconds: 400),
                  child: IconButton(onPressed: _swap, icon: const Icon(Icons.swap_horiz)),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickCurrency(pickingFrom: false),
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'To'),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'currency-$_to',
                            child: CircleAvatar(
                              child: Text(currencyByCode(_to)?.flag ?? _to.substring(0, 1)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoSizeText(
                              '$_to — ${currencyByCode(_to)?.name ?? ''}',
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _bounceCtrl,
              builder: (context, child) {
                final dy = -6 * Curves.elasticOut.transform(_bounceCtrl.value);
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: TextField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                inputFormatters: [AmountInputFormatter()],
              ),
            ),
            const SizedBox(height: 8),
            _RecentPairs(
              pairs: _recentPairs,
              onSelect: (pair) {
                final parts = pair.split('-');
                if (parts.length == 2) {
                  setState(() {
                    _from = parts[0];
                    _to = parts[1];
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            BlocBuilder<ConversionCubit, ConversionState>(
              buildWhen: (p, c) => p.loading != c.loading || (p.data == null) != (c.data == null),
              builder: (context, state) {
                final loading = state.loading;
                final success = !state.loading && state.data != null && state.error == null;
                return SizedBox(
                  width: double.infinity,
                  child: AnimatedConvertButton(
                    onPressed: _convert,
                    loading: loading,
                    success: success,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => TrendSheet(from: _from, to: _to),
                ),
                icon: const Icon(Icons.trending_up),
                label: const Text('5-Day Trend'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ConversionCubit, ConversionState>(
                builder: (context, state) {
                  Widget child;
                  if (state.loading) {
                    child = const ResultSkeleton();
                  } else if (state.data != null) {
                    final result = state.data!['result'];
                    final rate = result is Map<String, dynamic> ? (result['rate'] as num?) : null;
                    final target = result is Map<String, dynamic>
                        ? (result.values.firstWhere((v) => v is num, orElse: () => 0) as num)
                        : 0;
                    child = _ResultCard(value: target, rate: rate);
                  } else if (state.error != null) {
                    child = ResultError(
                      message: state.error!,
                      onRetry: () {
                        final val = double.tryParse(_amount.text.replaceAll(',', ''));
                        if (val != null && val > 0) {
                          context.read<ConversionCubit>().convert(_from, _to, val);
                        }
                      },
                    );
                  } else {
                    child = const Center(child: Text('Enter amount and convert'));
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: child,
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

class _ResultCard extends StatelessWidget {
  final num value;
  final num? rate;
  const _ResultCard({required this.value, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Converted Amount', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            CountUpText(
              value: value,
              fractionDigits: 4,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            if (rate != null) Text('Rate: ${rate!.toStringAsFixed(6)}'),
          ],
        ),
      ),
    );
  }
}
