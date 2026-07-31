import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:split_ease/core/theme/app_colors.dart';

class CalculatorBottomSheet extends StatefulWidget {
  final String initialValue;

  const CalculatorBottomSheet({super.key, this.initialValue = ''});

  @override
  State<CalculatorBottomSheet> createState() => _CalculatorBottomSheetState();
}

class _CalculatorBottomSheetState extends State<CalculatorBottomSheet> {
  String _expression = '';
  String _result = '';

  @override
  void initState() {
    super.initState();
    _expression = widget.initialValue;
  }

  void _onButtonPressed(String text) {
    setState(() {
      if (text == 'C') {
        _expression = '';
        _result = '';
      } else if (text == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (text == '=') {
        _calculateResult();
      } else if (text == 'Done') {
        _calculateResult();
        String finalValue = _result.isNotEmpty ? _result : _expression;
        if (finalValue == 'Error' || finalValue.isEmpty) {
          finalValue = '0';
        }
        Navigator.pop(context, finalValue);
      } else {
        if (_expression == '0' && !['+', '-', 'x', '/', '%', '.'].contains(text)) {
          _expression = text;
        } else {
          _expression += text;
        }
      }
    });
  }

  void _calculateResult() {
    if (_expression.isEmpty) return;
    try {
      final p = ShuntingYardParser();
      Expression exp = p.parse(_expression.replaceAll('x', '*'));
      ContextModel cm = ContextModel();
      double eval = RealEvaluator(cm).evaluate(exp).toDouble();
      
      // Format to remove trailing zeros if integer
      String formattedResult = eval.toString();
      if (formattedResult.endsWith('.0')) {
        formattedResult = formattedResult.substring(0, formattedResult.length - 2);
      }
      
      setState(() {
        _result = formattedResult;
        _expression = formattedResult;
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  Widget _buildButton(String text, {Color? textColor, Color? bgColor, double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: bgColor ?? Theme.of(context).ext.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _onButtonPressed(text),
            child: Container(
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Theme.of(context).ext.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).ext.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).ext.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).ext.inputFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).ext.border.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _expression.isEmpty ? '0' : _expression,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).ext.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_result.isNotEmpty && _result != _expression) ...[
                  const SizedBox(height: 8),
                  Text(
                    _result == 'Error' ? 'Error' : '= $_result',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _result == 'Error' ? Colors.red : Theme.of(context).ext.textTertiary,
                    ),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Keypad
          Row(
            children: [
              _buildButton('C', textColor: Colors.redAccent, bgColor: Colors.redAccent.withValues(alpha: 0.1)),
              _buildButton('⌫', textColor: AppColors.primaryTeal),
              _buildButton('%', textColor: AppColors.primaryTeal),
              _buildButton('/', textColor: AppColors.primaryTeal),
            ],
          ),
          Row(
            children: [
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
              _buildButton('x', textColor: AppColors.primaryTeal),
            ],
          ),
          Row(
            children: [
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
              _buildButton('-', textColor: AppColors.primaryTeal),
            ],
          ),
          Row(
            children: [
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
              _buildButton('+', textColor: AppColors.primaryTeal),
            ],
          ),
          Row(
            children: [
              _buildButton('.'),
              _buildButton('0'),
              _buildButton('=', textColor: Colors.white, bgColor: AppColors.primaryTeal),
              _buildButton('Done', textColor: Colors.white, bgColor: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}
