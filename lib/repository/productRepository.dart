import 'package:dio_project/api_client.dart';
import 'package:dio_project/model/productDio_model.dart';
import 'package:dio_project/model/productEntity.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<ProductEntity>> getProducts() async {
    final response = await _apiClient.dio.get('/products');

    if (response.statusCode == 200) {
      final List rawList = response.data as List;

      return rawList
          .map((json) => ProductDto.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}