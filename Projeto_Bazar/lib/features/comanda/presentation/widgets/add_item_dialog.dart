import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter/services.dart';
import '../../../../shared/utils/currency_input_formatter.dart';

class AddItemDialog extends StatefulWidget {
  final Function(String descricao, double valor, int quantidade) onAdd;

  const AddItemDialog({super.key, required this.onAdd});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  int _quantidade = 1;

  void _submit() {
    final descricao = _descricaoController.text.trim();
    // Remove separadores de milhar e converte vírgula decimal em ponto
    String valorLimpo = _valorController.text.replaceAll('.', '').replaceAll(',', '.');
    final valor = double.tryParse(valorLimpo);

    if (descricao.isNotEmpty && valor != null && valor >= 0) {
      widget.onAdd(descricao, valor, _quantidade);
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
              'Adicionar Consumo',
              style: TextStyle(color: AppColors.accentCream, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _descricaoController,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.backgroundLight,
                hintText: 'Produto (Ex: Coxinha)',
                hintStyle: const TextStyle(color: AppColors.cardBrown),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
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
                hintText: 'Valor unitário (R\$)',
                hintStyle: const TextStyle(color: AppColors.cardBrown),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantidade:', style: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.cardPink),
                      onPressed: () {
                        if (_quantidade > 1) setState(() => _quantidade--);
                      },
                    ),
                    Text('$_quantidade', style: const TextStyle(color: AppColors.textPrimaryLight, fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.accentCream),
                      onPressed: () {
                        setState(() => _quantidade++);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardPink,
                foregroundColor: AppColors.textPrimaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('ADICIONAR À COMANDA', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
