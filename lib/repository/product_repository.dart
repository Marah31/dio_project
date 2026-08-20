import 'package:dio/dio.dart';
import 'package:dio_project/domain/entity/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    CancelToken? cancelToken});

    Future<void> updateFavorite({
    required int productId,
    required bool isFavorite,
    bool forceFailure,
  });
}