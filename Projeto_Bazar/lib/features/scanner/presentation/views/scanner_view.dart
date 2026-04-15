import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../comanda/presentation/views/comanda_detail_view.dart';
import '../../../comanda/data/repositories/comanda_repository.dart';
import '../../../comanda/data/services/comanda_remote_service.dart';
import '../../../comanda/presentation/viewmodels/comanda_detail_viewmodel.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../../../casal/casal_module.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final ScannerViewModel _viewModel = ScannerViewModel();

  void _navigateToComanda(String coupleId) {
    final repo = ComandaRepository(ComandaRemoteService());
    final comandaViewModel = ComandaDetailViewModel(repo);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComandaDetailView(
          viewModel: comandaViewModel,
          coupleId: coupleId,
        ),
      ),
    ).then((_) => _viewModel.reset());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificar Casal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CasalModule.build()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border.all(color: AppColors.accentCream, width: 2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCream.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null && _viewModel.scannedId == null) {
                        _viewModel.onScan(barcode.rawValue!);
                        _navigateToComanda(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner, size: 48, color: AppColors.accentCream.withAlpha((0.5 * 255).toInt())),
                const SizedBox(height: 16),
                const Text(
                  'Aponte para o QR Code para abrir a comanda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
