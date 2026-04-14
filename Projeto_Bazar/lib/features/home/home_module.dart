import 'package:flutter/material.dart';
import 'data/services/home_service.dart';
import 'data/repositories/home_repository.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/views/home_view.dart';

class HomeModule {
  static Widget build() {
    // Basic dependency injection manually managed for now.
    final service = HomeService();
    final repository = HomeRepository(service);
    final viewModel = HomeViewModel(repository);

    return HomeView(viewModel: viewModel);
  }
}
