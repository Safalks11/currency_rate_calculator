part of 'conversion_cubit.dart';

class ConversionState extends Equatable {
  final bool loading;
  final ConversionResult? result;
  final String? error;

  const ConversionState({required this.loading, required this.result, required this.error});
  const ConversionState.initial() : this(loading: false, result: null, error: null);
  const ConversionState.loading() : this(loading: true, result: null, error: null);
  const ConversionState.success(ConversionResult r) : this(loading: false, result: r, error: null);
  const ConversionState.error(String e) : this(loading: false, result: null, error: e);

  @override
  List<Object?> get props => [loading, result, error];
}
