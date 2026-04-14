import '../models/product_model.dart';
import '../services/home_service.dart';

class HomeRepository {
  final HomeService _service;

  HomeRepository(this._service);

  Future<List<ProductModel>> getProducts() async {
    try {
      return await _service.fetchProducts();
    } catch (e) {
      throw Exception('Failed to fetch products');
    }
  }
}
