import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Apenas números
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Converte para centavos
    double value = double.parse(cleanText) / 100;

    // Formata como real (sem o símbolo R$ para não conflitar com o foco do campo, 
    // ou com o símbolo se desejado, mas vamos manter limpo conforme pedido)
    final formatter = NumberFormat.simpleCurrency(locale: 'pt_BR', name: '');
    String newText = formatter.format(value).trim();

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}
