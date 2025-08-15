import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AmountInputFormatter extends TextInputFormatter {
  final NumberFormat _nf = NumberFormat('#,##0.########');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9\.]'), '');
    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final parts = text.split('.');
    String normalized = parts.length > 1 ? '${parts.first}.${parts.sublist(1).join()}' : text;
    final num? value = num.tryParse(normalized);
    if (value == null) {
      return newValue.copyWith(text: newValue.text, selection: newValue.selection);
    }
    final formatted = _nf.format(value);
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
