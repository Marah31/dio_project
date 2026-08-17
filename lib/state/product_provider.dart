import 'package:dio_project/api_client.dart';
import 'package:dio_project/domain/entity/product_entity.dart';
import 'package:dio_project/repository/product_repository.dart';
import 'package:dio_project/repository/product_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((Ref ref) {
  final client = ApiClient();
  ref.onDispose(() => client.dispose());
  return client;
});

final productRepositoryProvider = Provider<ProductRepository>((Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRepositoryImpl(apiClient);
});

final productsProvider = FutureProvider<List<ProductEntity>>((Ref ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});
