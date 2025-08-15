import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/currency_repository.dart';
part 'conversion_state.dart';

class ConversionCubit extends Cubit<ConversionState> {
  final CurrencyRepository _repo;

  ConversionCubit(this._repo) : super(const ConversionState.initial());

  Future<void> convert(String from, String to, double amount) async {
    emit(const ConversionState.loading());
    try {
      final data = await _repo.convert(from: from, to: to, amount: amount);
      emit(ConversionState.success(data));
    } catch (e) {
      emit(ConversionState.error(e.toString()));
    }
  }
}
