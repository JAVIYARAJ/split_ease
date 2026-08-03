import 'package:flutter/services.dart';
import 'app_formatter.dart';

/// TextInputFormatter that formats numbers with comma thousands separation
/// as the user types (e.g. 10000 -> 10,000).
class AmountInputFormatter extends TextInputFormatter {
  final bool allowDecimals;
  final int maxDecimalDigits;

  AmountInputFormatter({
    this.allowDecimals = true,
    this.maxDecimalDigits = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String text = newValue.text;
    final buffer = StringBuffer();
    bool hasDecimal = false;
    int decimalPlaces = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (RegExp(r'[0-9]').hasMatch(char)) {
        if (hasDecimal) {
          if (decimalPlaces < maxDecimalDigits) {
            buffer.write(char);
            decimalPlaces++;
          }
        } else {
          buffer.write(char);
        }
      } else if (char == '.' && allowDecimals && !hasDecimal) {
        hasDecimal = true;
        buffer.write(char);
      }
    }

    final cleanText = buffer.toString();
    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    int selectionIndex = newValue.selection.end;
    if (selectionIndex < 0) selectionIndex = 0;
    if (selectionIndex > newValue.text.length) selectionIndex = newValue.text.length;

    int digitsAndDotsBeforeCursor = 0;
    bool decimalSeenBeforeCursor = false;
    int decPlacesBeforeCursor = 0;

    for (int i = 0; i < selectionIndex; i++) {
      final char = newValue.text[i];
      if (RegExp(r'[0-9]').hasMatch(char)) {
        if (decimalSeenBeforeCursor) {
          if (decPlacesBeforeCursor < maxDecimalDigits) {
            digitsAndDotsBeforeCursor++;
            decPlacesBeforeCursor++;
          }
        } else {
          digitsAndDotsBeforeCursor++;
        }
      } else if (char == '.' && allowDecimals && !decimalSeenBeforeCursor) {
        decimalSeenBeforeCursor = true;
        digitsAndDotsBeforeCursor++;
      }
    }

    final parts = cleanText.split('.');
    final intPart = parts[0];
    final String decPart = parts.length > 1 ? parts[1] : '';

    String formattedIntPart = '';
    if (intPart.isNotEmpty) {
      final numValue = num.tryParse(intPart);
      if (numValue != null) {
        formattedIntPart = AppFormatter.formatNumber(numValue);
      } else {
        formattedIntPart = intPart;
      }
    }

    String formattedText = formattedIntPart;
    if (allowDecimals && cleanText.contains('.')) {
      formattedText += '.$decPart';
    }

    int newCursorOffset = 0;
    int matchedCount = 0;

    for (int i = 0; i < formattedText.length; i++) {
      if (matchedCount >= digitsAndDotsBeforeCursor) {
        break;
      }
      final char = formattedText[i];
      if (RegExp(r'[0-9\.]').hasMatch(char)) {
        matchedCount++;
      }
      newCursorOffset = i + 1;
    }

    if (newCursorOffset > formattedText.length) {
      newCursorOffset = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }
}
