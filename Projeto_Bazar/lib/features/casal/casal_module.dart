import 'package:flutter/material.dart';
import 'data/repositories/casal_repository.dart';
import 'data/services/casal_remote_service.dart';
import '../comanda/data/repositories/comanda_repository.dart';
import '../comanda/data/services/comanda_remote_service.dart';
import 'presentation/viewmodels/casal_management_viewmodel.dart';
import 'presentation/views/casal_management_view.dart';

class CasalModule {
  static Widget build() {
    final service = CasalRemoteService();
    final comandaService = ComandaRemoteService();
    
    final repository = CasalRepository(service, comandaService);
    final comandaRepository = ComandaRepository(comandaService);
    
    final viewModel = CasalManagementViewModel(repository, comandaRepository);

    return CasalManagementView(viewModel: viewModel);
  }
}
