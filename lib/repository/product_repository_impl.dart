import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:dio_project/api_client.dart';
import 'package:dio_project/domain/entity/product_entity.dart';
import 'package:dio_project/model/product_dto.dart';
import 'package:dio_project/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient;

  ProductRepositoryImpl(this._apiClient);

  @override
  Future<List<ProductEntity>> getProducts() async {
    try {
      final response = await _apiClient.dio.get('/products');
      return await Isolate.run(() {
        final List rawList = response.data as List;
        return rawList
            .map(
              (json) =>
                  ProductDto.fromJson(json as Map<String, dynamic>).toEntity(),
            )
            .toList();
      });
    } on DioException catch (error) {
      throw Exception('Failed to load products: $error');
    }
  }
}
