import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/conversion_result.dart';
import '../../domain/usecases/convert_currency.dart';
part 'conversion_state.dart';

class ConversionCubit extends Cubit<ConversionState> {
  final ConvertCurrency _convert;

  ConversionCubit(this._convert) : super(const ConversionState.initial());

  Future<void> convert(String from, String to, double amount) async {
    emit(const ConversionState.loading());
    try {
      final result = await _convert(from: from, to: to, amount: amount);
      emit(ConversionState.success(result));
    } catch (e) {
      emit(ConversionState.error(e.toString()));
    }
  }
}
