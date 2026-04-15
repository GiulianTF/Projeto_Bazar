import 'package:flutter/material.dart';
import 'data/repositories/casal_repository.dart';
import 'data/services/casal_remote_service.dart';
import 'presentation/viewmodels/casal_management_viewmodel.dart';
import 'presentation/views/casal_management_view.dart';

class CasalModule {
  static Widget build() {
    final service = CasalRemoteService();
    final repository = CasalRepository(service);
    final viewModel = CasalManagementViewModel(repository);

    return CasalManagementView(viewModel: viewModel);
  }
}
