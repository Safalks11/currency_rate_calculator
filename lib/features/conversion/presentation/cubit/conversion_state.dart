part of 'conversion_cubit.dart';

class ConversionState extends Equatable {
  final bool loading;
  final Map<String, dynamic>? data;
  final String? error;

  const ConversionState({required this.loading, required this.data, required this.error});
  const ConversionState.initial() : this(loading: false, data: null, error: null);
  const ConversionState.loading() : this(loading: true, data: null, error: null);
  const ConversionState.success(Map<String, dynamic> d) : this(loading: false, data: d, error: null);
  const ConversionState.error(String e) : this(loading: false, data: null, error: e);

  @override
  List<Object?> get props => [loading, data, error];
}
