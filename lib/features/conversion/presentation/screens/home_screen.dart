import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/currencies.dart';
import '../../../../core/router/app_route.dart';
import '../../presentation/cubit/conversion_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../widgets/amount_input_formatter.dart';
import '../widgets/animated_convert_button.dart';
import '../widgets/currency_picker_sheet.dart';
import '../widgets/result_card.dart';
import '../widgets/result_error.dart';
import '../widgets/result_skeleton.dart';
import '../widgets/trend_sheet.dart';
import '../cubit/conversion_form_cubit.dart';

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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _amount = TextEditingController(text: '1');
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
    HapticFeedback.lightImpact();
    context.read<ConversionFormCubit>().swap();
  }

  Future<void> _pickCurrency({required bool pickingFrom}) async {
    final form = context.read<ConversionFormCubit>().state;
    final current = pickingFrom ? form.from : form.to;
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CurrencyPickerSheet(selectedCode: current),
    );
    if (code != null && code.isNotEmpty) {
      if (pickingFrom) {
        context.read<ConversionFormCubit>().setFrom(code);
      } else {
        context.read<ConversionFormCubit>().setTo(code);
      }
    }
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
    HapticFeedback.mediumImpact();
    final form = context.read<ConversionFormCubit>().state;
    context.read<ConversionCubit>().convert(form.from, form.to, val);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: Colors.transparent,
        actions: [IconButton(onPressed: _showLogoutSheet, icon: const Icon(Icons.logout_rounded))],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withValues(alpha: 0.05)),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(height: 100),
              BlocBuilder<ConversionFormCubit, ConversionFormState>(
                builder: (context, formState) {
                  return Card(
                    elevation: 1,
                    color: Colors.white60,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(child: _currencyTile(formState.from, true)),
                          AnimatedRotation(
                            turns: formState.swapTurns,
                            duration: const Duration(milliseconds: 400),
                            child: Tooltip(
                              message: 'Swap',
                              child: IconButton.filledTonal(
                                icon: const Icon(Icons.swap_horiz, size: 24),
                                onPressed: _swap,
                              ),
                            ),
                          ),
                          Expanded(child: _currencyTile(formState.to, false)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<ConversionFormCubit, ConversionFormState>(
                builder: (context, formState) {
                  return Card(
                    elevation: 1,
                    color: Colors.white60,

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _bounceCtrl,
                            builder: (context, child) {
                              final dy = -6 * Curves.elasticOut.transform(_bounceCtrl.value);
                              return Transform.translate(offset: Offset(0, dy), child: child);
                            },
                            child: TextField(
                              controller: _amount,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixIcon: const Icon(Icons.calculate_rounded),
                                suffixIcon: (formState.amount.isNotEmpty)
                                    ? IconButton(
                                        tooltip: 'Clear',
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _amount.clear();
                                          context.read<ConversionFormCubit>().clearAmount();
                                        },
                                      )
                                    : null,
                                helperText: 'Enter the amount to convert',
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              inputFormatters: [AmountInputFormatter()],
                              onChanged: (v) => context.read<ConversionFormCubit>().setAmount(v),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _RecentPairs(
                            pairs: formState.recentPairs,
                            onSelect: (pair) =>
                                context.read<ConversionFormCubit>().selectPair(pair),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<ConversionCubit, ConversionState>(
                buildWhen: (p, c) =>
                    p.loading != c.loading || (p.result == null) != (c.result == null),
                builder: (context, state) {
                  final loading = state.loading;
                  final success = !state.loading && state.result != null && state.error == null;
                  return AnimatedConvertButton(
                    onPressed: _convert,
                    loading: loading,
                    success: success,
                  );
                },
              ),

              const SizedBox(height: 16),
              BlocBuilder<ConversionCubit, ConversionState>(
                builder: (context, state) {
                  Widget child;
                  if (state.loading) {
                    child = const ResultSkeleton();
                  } else if (state.result != null) {
                    final res = state.result!;
                    final rate = res.rate;
                    final target = res.result.values.isNotEmpty ? res.result.values.first : 0.0;
                    child = ResultCard(value: target, rate: rate);
                  } else if (state.error != null) {
                    child = ResultError(message: state.error!, onRetry: _convert);
                  } else {
                    child = const Center(
                      child: Text(
                        'Enter amount and convert',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: child,
                  );
                },
              ),
              const SizedBox(height: 8),
              BlocBuilder<ConversionFormCubit, ConversionFormState>(
                builder: (context, formState) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: surfaceColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => TrendSheet(from: formState.from, to: formState.to),
                      ),
                      icon: const Icon(Icons.trending_up),
                      label: const Text('5-Day Trend'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutSheet() async {
    final theme = Theme.of(context);

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Sign out',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to sign out of your account?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Sign out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      if (mounted) context.read<AuthCubit>().signOut();
      if (mounted) context.go(AppRouter.loginRoute);
    }
  }

  Widget _currencyTile(String code, bool pickingFrom) {
    final currency = currencyByCode(code);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _pickCurrency(pickingFrom: pickingFrom),
      borderRadius: BorderRadius.circular(12),
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            Hero(
              tag: 'currency-$code',
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  currency?.flag ?? code.substring(0, 1),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    currency?.name ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.expand_more, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
