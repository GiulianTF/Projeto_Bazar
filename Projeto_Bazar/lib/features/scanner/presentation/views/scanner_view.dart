import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../comanda/presentation/views/comanda_detail_view.dart';
import '../../../comanda/data/repositories/comanda_repository.dart';
import '../../../comanda/data/services/comanda_local_service.dart';
import '../../../comanda/presentation/viewmodels/comanda_detail_viewmodel.dart';
import '../viewmodels/scanner_viewmodel.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final ScannerViewModel _viewModel = ScannerViewModel();
  final TextEditingController _manualController = TextEditingController();

  void _navigateToComanda(String coupleId) {
    final repo = ComandaRepository(ComandaLocalService());
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
      appBar: AppBar(title: const Text('Identificar Casal')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border.all(color: AppColors.accentCream, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
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
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.cardBrown,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ou insira o código manualmente:', style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualController,
                          style: const TextStyle(color: AppColors.textPrimaryDark),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.backgroundLight,
                            hintText: 'Ex: CASAL-123',
                            hintStyle: const TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_manualController.text.trim().isNotEmpty) {
                            _navigateToComanda(_manualController.text.trim());
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('ABRIR COMANDA'),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
