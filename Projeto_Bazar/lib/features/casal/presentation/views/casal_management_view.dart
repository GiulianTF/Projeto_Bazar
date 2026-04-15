import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/casal_management_viewmodel.dart';
import '../widgets/qr_viewer_dialog.dart';

class CasalManagementView extends StatefulWidget {
  final CasalManagementViewModel viewModel;

  const CasalManagementView({super.key, required this.viewModel});

  @override
  State<CasalManagementView> createState() => _CasalManagementViewState();
}

class _CasalManagementViewState extends State<CasalManagementView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadCasais();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _showAddCasalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBrown,
        title: const Text('Novo Casal', style: TextStyle(color: AppColors.textPrimaryLight)),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimaryLight),
          decoration: const InputDecoration(
            hintText: 'Nome do Casal/Comanda',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accentCream)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                widget.viewModel.createCasal(_nameController.text.trim());
                _nameController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('CRIAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Comandas')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCasalDialog,
        backgroundColor: AppColors.accentCream,
        child: const Icon(Icons.add, color: AppColors.textPrimaryDark),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.viewModel.isLoading && widget.viewModel.casais.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.viewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.viewModel.loadCasais,
              child: const Text('TENTAR NOVAMENTE'),
            ),
          ],
        ),
      );
    }

    if (widget.viewModel.casais.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum casal cadastrado.\nToque no + para adicionar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.viewModel.casais.length,
      itemBuilder: (context, index) {
        final casal = widget.viewModel.casais[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              casal.nome ?? 'Sem nome',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text('ID: ${casal.qrCode}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_2, color: AppColors.accentCream),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => QrViewerDialog(
                        qrData: casal.qrCode,
                        title: casal.nome ?? 'Casal',
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    // Confirmação simples de exclusão
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.backgroundDark,
                        title: const Text('Excluir?'),
                        content: Text('Deseja excluir o cadastro de ${casal.nome}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NÃO')),
                          TextButton(
                            onPressed: () {
                              widget.viewModel.deleteCasal(casal.id);
                              Navigator.pop(context);
                            },
                            child: const Text('SIM', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
