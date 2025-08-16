import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversionFormState extends Equatable {
  final String from;
  final String to;
  final String amount;
  final double swapTurns;
  final List<String> recentPairs;

  const ConversionFormState({
    required this.from,
    required this.to,
    required this.amount,
    required this.swapTurns,
    required this.recentPairs,
  });

  const ConversionFormState.initial()
      : this(from: 'USD', to: 'INR', amount: '1', swapTurns: 0, recentPairs: const []);

  ConversionFormState copyWith({
    String? from,
    String? to,
    String? amount,
    double? swapTurns,
    List<String>? recentPairs,
  }) => ConversionFormState(
        from: from ?? this.from,
        to: to ?? this.to,
        amount: amount ?? this.amount,
        swapTurns: swapTurns ?? this.swapTurns,
        recentPairs: recentPairs ?? this.recentPairs,
      );

  @override
  List<Object?> get props => [from, to, amount, swapTurns, recentPairs];
}

class ConversionFormCubit extends Cubit<ConversionFormState> {
  ConversionFormCubit() : super(const ConversionFormState.initial());

  void setFrom(String code) {
    emit(state.copyWith(from: code, recentPairs: _rememberPair(state.recentPairs, code, state.to)));
  }

  void setTo(String code) {
    emit(state.copyWith(to: code, recentPairs: _rememberPair(state.recentPairs, state.from, code)));
  }

  void selectPair(String pair) {
    final parts = pair.split('-');
    if (parts.length == 2) {
      emit(state.copyWith(from: parts[0], to: parts[1]));
    }
  }

  void swap() {
    final nextTurns = state.swapTurns + 1;
    final from = state.to;
    final to = state.from;
    emit(state.copyWith(
      from: from,
      to: to,
      swapTurns: nextTurns,
      recentPairs: _rememberPair(state.recentPairs, from, to),
    ));
  }

  void setAmount(String value) {
    emit(state.copyWith(amount: value));
  }

  void clearAmount() {
    emit(state.copyWith(amount: ''));
  }

  List<String> _rememberPair(List<String> current, String from, String to) {
    final pair = '$from-$to';
    final list = List<String>.from(current);
    list.remove(pair);
    list.insert(0, pair);
    if (list.length > 6) list.removeLast();
    return list;
  }
}
