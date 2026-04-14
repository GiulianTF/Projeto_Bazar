import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/comanda_status.dart';
import '../viewmodels/comanda_detail_viewmodel.dart';
import '../widgets/add_item_dialog.dart';
import 'package:intl/intl.dart';

class ComandaDetailView extends StatefulWidget {
  final ComandaDetailViewModel viewModel;
  final String coupleId;

  const ComandaDetailView({super.key, required this.viewModel, required this.coupleId});

  @override
  State<ComandaDetailView> createState() => _ComandaDetailViewState();
}

class _ComandaDetailViewState extends State<ComandaDetailView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadComanda(widget.coupleId);
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onAdd: (descricao, valor, quantidade) {
          widget.viewModel.addItem(descricao, valor, quantidade);
        },
      ),
    );
  }

  void _checkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Confirmar Pagamento', style: TextStyle(color: AppColors.textPrimaryLight)),
        content: Text('Deseja finalizar o pagamento no valor de ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(widget.viewModel.comanda?.total ?? 0)}?', style: const TextStyle(color: AppColors.textPrimaryLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.cardPink)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBrown),
            onPressed: () {
              Navigator.pop(context);
              widget.viewModel.pagarComanda();
            },
            child: const Text('Pagar', style: TextStyle(color: AppColors.textPrimaryLight)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comanda = widget.viewModel.comanda;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comanda: ${widget.coupleId}'),
        centerTitle: true,
      ),
      body: widget.viewModel.isLoading && comanda == null
          ? const Center(child: CircularProgressIndicator())
          : widget.viewModel.errorMessage != null
              ? Center(child: Text(widget.viewModel.errorMessage!, style: const TextStyle(color: AppColors.cardPink)))
              : comanda == null
                  ? const Center(child: Text('Nenhuma comanda encontrada.', style: TextStyle(color: AppColors.textPrimaryLight)))
                  : Column(
                      children: [
                        _buildStatusHeader(comanda.status),
                        if (widget.viewModel.isLoading) const LinearProgressIndicator(color: AppColors.accentCream),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: comanda.itens.length,
                            itemBuilder: (context, index) {
                              final item = comanda.itens[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(item.descricao, style: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
                                  subtitle: Text('${item.quantidade}x ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.valor)}', style: const TextStyle(color: AppColors.backgroundLight)),
                                  trailing: Text(NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.quantidade * item.valor), style: const TextStyle(color: AppColors.accentCream, fontSize: 16)),
                                ),
                              );
                            },
                          ),
                        ),
                        _buildFooter(comanda.total, comanda.status),
                      ],
                    ),
      floatingActionButton: comanda != null && comanda.status != ComandaStatus.paga
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accentCream,
              foregroundColor: AppColors.textPrimaryDark,
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add_shopping_cart, color: AppColors.textPrimaryDark),
              label: const Text('ADICIONAR ITEM', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildStatusHeader(ComandaStatus status) {
    Color statusColor;
    String statusText;

    if (status == ComandaStatus.paga) {
      statusColor = Colors.green;
      statusText = 'PAGA';
    } else {
      statusColor = AppColors.cardPink;
      statusText = 'ABERTA';
    }

    return Container(
      width: double.infinity,
      color: statusColor.withAlpha(51),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'STATUS: $statusText',
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _buildFooter(double total, ComandaStatus status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardBrown,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total da Comanda', style: TextStyle(color: AppColors.backgroundLight, fontSize: 14)),
                Text(
                  NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(total),
                  style: const TextStyle(color: AppColors.textPrimaryLight, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (status != ComandaStatus.paga)
              ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('FECHAR CONTA', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            else
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
          ],
        ),
      ),
    );
  }
}
