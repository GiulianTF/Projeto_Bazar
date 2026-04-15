import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../comanda/presentation/views/comanda_detail_view.dart';
import '../../../comanda/data/repositories/comanda_repository.dart';
import '../../../comanda/data/services/comanda_remote_service.dart';
import '../../../comanda/presentation/viewmodels/comanda_detail_viewmodel.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../../../casal/casal_module.dart';
import '../../../casal/data/repositories/casal_repository.dart';
import '../../../casal/data/services/casal_remote_service.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final ScannerViewModel _viewModel = ScannerViewModel();

  void _navigateToComanda(String coupleId) {
    final comandaService = ComandaRemoteService();
    final comandaRepo = ComandaRepository(comandaService);
    final casalRepo = CasalRepository(CasalRemoteService(), comandaService);
    final comandaViewModel = ComandaDetailViewModel(comandaRepo, casalRepo);

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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              iconSize: 32,
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CasalModule.build()),
                );
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border.all(color: AppColors.accentCream, width: 3),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCream.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(29),
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
            const SizedBox(height: 48),
            Icon(
              Icons.qr_code_scanner,
              size: 56,
              color: AppColors.accentCream.withAlpha((0.6 * 255).toInt()),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                'Aponte para o QR Code para abrir a comanda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimaryLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 64), // Extra space at bottom to keep it visually "centered" vertically as a group
          ],
        ),
      ),
    );
  }
}
