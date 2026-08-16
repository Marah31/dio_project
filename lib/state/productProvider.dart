import 'package:dio_project/api_client.dart';
import 'package:dio_project/model/productEntity.dart';
import 'package:dio_project/repository/productRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final apiClientProvider = Provider((ref) => ApiClient());

final productRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRepository(apiClient);
});

final productsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});