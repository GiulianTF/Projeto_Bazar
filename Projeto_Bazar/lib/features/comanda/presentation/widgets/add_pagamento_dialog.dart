import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
    // Inicia com o valor do saldo caso ele queira quitar tudo de vez
    _valorController = TextEditingController(text: widget.saldoDevedor.toStringAsFixed(2).replaceAll('.', ','));
  }

  void _submit() {
    final valorStr = _valorController.text.trim().replaceAll(',', '.');
    final valor = double.tryParse(valorStr);

    if (valor != null && valor > 0) {
      widget.onAdd(valor);
      Navigator.pop(context);
    }
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
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundLight,
                labelText: 'Valor recebido (R\$)',
                labelStyle: const TextStyle(color: AppColors.cardBrown),
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
