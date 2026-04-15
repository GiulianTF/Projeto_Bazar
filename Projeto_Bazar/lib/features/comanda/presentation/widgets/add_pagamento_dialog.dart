import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter/services.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import 'package:intl/intl.dart';

class AddPagamentoDialog extends StatefulWidget {
  final double saldoDevedor;
  final Function(double valor) onAdd;

  const AddPagamentoDialog({super.key, required this.saldoDevedor, required this.onAdd});

  @override
  State<AddPagamentoDialog> createState() => _AddPagamentoDialogState();
}

class _AddPagamentoDialogState extends State<AddPagamentoDialog> {
  late final TextEditingController _valorController;

  @override
  void initState() {
    super.initState();
    // Inicia com o valor do saldo formatado para a máscara (ex: 12.34 -> "12,34")
    final formatter = NumberFormat.simpleCurrency(locale: 'pt_BR', name: '');
    String initialValue = formatter.format(widget.saldoDevedor).trim();
    _valorController = TextEditingController(text: initialValue);
  }

  void _submit() {
    // Remove separadores de milhar e converte vírgula decimal em ponto para parsear
    String valorLimpo = _valorController.text.replaceAll('.', '').replaceAll(',', '.');
    final valor = double.tryParse(valorLimpo);

    if (valor == null || valor <= 0) return;

    if (valor > widget.saldoDevedor + 0.001) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundDark,
          title: const Text('Valor Inválido', style: TextStyle(color: AppColors.cardPink)),
          content: Text(
            'Não é possível receber mais do que o saldo em aberto.\n\n'
            'Saldo atual: R\$ ${widget.saldoDevedor.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(color: AppColors.textPrimaryLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ENTENDIDO', style: TextStyle(color: AppColors.cardPink)),
            ),
          ],
        ),
      );
      return;
    }

    widget.onAdd(valor);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Receber Valor',
              style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimaryDark),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundLight,
                hintText: 'Valor recebido (R\$)',
                hintStyle: const TextStyle(color: AppColors.cardBrown),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                foregroundColor: AppColors.textPrimaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CONFIRMAR RECEBIMENTO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
