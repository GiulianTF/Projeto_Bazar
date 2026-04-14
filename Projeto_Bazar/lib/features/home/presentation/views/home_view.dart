import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/product_card.dart';

class HomeView extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.errorMessage != null) {
      return Center(child: Text(widget.viewModel.errorMessage!));
    }

    if (widget.viewModel.products.isEmpty) {
      return const Center(child: Text('No products available.'));
    }

    return ListView.builder(
      itemCount: widget.viewModel.products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: widget.viewModel.products[index]);
      },
    );
  }
}
