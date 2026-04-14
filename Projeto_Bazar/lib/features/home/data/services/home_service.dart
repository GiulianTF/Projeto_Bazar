import '../models/product_model.dart';

class HomeService {
  Future<List<ProductModel>> fetchProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return [
      ProductModel(id: '1', title: 'Product 1', price: 29.99),
      ProductModel(id: '2', title: 'Product 2', price: 49.99),
    ];
  }
}
