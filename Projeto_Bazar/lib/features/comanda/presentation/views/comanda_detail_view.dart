import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/comanda_status.dart';
import '../../../../shared/models/item_model.dart';
import '../../../../shared/models/pagamento_model.dart';
import '../viewmodels/comanda_detail_viewmodel.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/add_pagamento_dialog.dart';
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

  void _showAddPagamentoDialog(double saldo) {
    showDialog(
      context: context,
      builder: (context) => AddPagamentoDialog(
        saldoDevedor: saldo,
        onAdd: (valor) {
          widget.viewModel.addPagamento(valor);
        },
      ),
    );
  }

  void _encerrar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Encerrar Comanda', style: TextStyle(color: AppColors.textPrimaryLight)),
        content: const Text('O saldo está zerado. Deseja fechar definitivamente o ciclo dessa comanda?', style: TextStyle(color: AppColors.textPrimaryLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.cardPink)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBrown),
            onPressed: () {
              Navigator.pop(context);
              widget.viewModel.encerrarComanda();
            },
            child: const Text('Encerrar', style: TextStyle(color: AppColors.textPrimaryLight)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comanda = widget.viewModel.comanda;

    List<dynamic> linhaDoTempo = [];
    if (comanda != null) {
      linhaDoTempo = [...comanda.itens, ...comanda.pagamentos];
      linhaDoTempo.sort((a, b) {
        final dateA = (a as dynamic).dataHora as DateTime;
        final dateB = (b as dynamic).dataHora as DateTime;
        return dateB.compareTo(dateA); // Do mais recente para o mais antigo
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coupleId),
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
                            itemCount: linhaDoTempo.length,
                            itemBuilder: (context, index) {
                              final itemTimeline = linhaDoTempo[index];
                              
                              if (itemTimeline is ItemModel) {
                                return _buildCardItem(itemTimeline);
                              } else if (itemTimeline is PagamentoModel) {
                                return _buildCardPagamento(itemTimeline);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        _buildFooter(comanda.totalConsumido, comanda.totalPago, comanda.saldoDevedor, comanda.status),
                      ],
                    ),
      floatingActionButton: comanda != null && comanda.status != ComandaStatus.paga
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (comanda.saldoDevedor > 0)
                  FloatingActionButton.extended(
                    heroTag: 'btn_pagar',
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: AppColors.textPrimaryDark,
                    onPressed: () => _showAddPagamentoDialog(comanda.saldoDevedor),
                    icon: const Icon(Icons.attach_money),
                    label: const Text('RECEBER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  heroTag: 'btn_add',
                  backgroundColor: AppColors.cardPink,
                  foregroundColor: AppColors.textPrimaryDark,
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('ADICIONAR ITEM', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildCardItem(ItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const CircleAvatar(backgroundColor: AppColors.cardPink, child: Icon(Icons.shopping_bag, color: Colors.white, size: 20)),
          title: Text(item.descricao, style: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
          subtitle: Text('${item.quantidade}x ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.valor)}', style: const TextStyle(color: AppColors.backgroundLight)),
          trailing: Text('- ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.quantidade * item.valor)}', style: const TextStyle(color: AppColors.cardPink, fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Data e Hora:', style: TextStyle(color: AppColors.backgroundLight)),
                  Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(item.dataHora), style: const TextStyle(color: AppColors.textPrimaryLight)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCardPagamento(PagamentoModel pgm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.green.shade900.withAlpha(50),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.green.shade700, width: 1),
        borderRadius: BorderRadius.circular(16)
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(backgroundColor: Colors.green.shade700, child: const Icon(Icons.payment, color: Colors.white, size: 20)),
          title: const Text('Abatimento', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          subtitle: const Text('Pagamento recebido', style: TextStyle(color: AppColors.backgroundLight)),
          trailing: Text('+ ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(pgm.valor)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Data e Hora:', style: TextStyle(color: AppColors.backgroundLight)),
                  Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(pgm.dataHora), style: const TextStyle(color: Colors.greenAccent)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ComandaStatus status) {
    Color statusColor;
    String statusText;

    if (status == ComandaStatus.paga) {
      statusColor = Colors.greenAccent;
      statusText = 'ENCERRADA';
    } else {
      statusColor = AppColors.cardPink;
      statusText = 'EM ABERTO';
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

  Widget _buildFooter(double consumido, double pago, double saldo, ComandaStatus status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardBrown,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Consumido', style: TextStyle(color: AppColors.backgroundLight)),
                Text(NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(consumido), style: const TextStyle(color: AppColors.textPrimaryLight)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Recebido', style: TextStyle(color: AppColors.backgroundLight)),
                Text(NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(pago), style: const TextStyle(color: Colors.greenAccent)),
              ],
            ),
            const Divider(color: AppColors.backgroundLight, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SALDO DEVENDO', style: TextStyle(color: AppColors.backgroundLight, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(
                      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(saldo),
                      style: TextStyle(color: saldo == 0 ? Colors.greenAccent : AppColors.cardPink, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (status != ComandaStatus.paga)
                  ElevatedButton(
                    onPressed: saldo == 0 && consumido > 0 ? _encerrar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade800,
                      disabledForegroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('ENCERRAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
