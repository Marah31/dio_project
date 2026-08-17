import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:dio_project/core/error/app_exception.dart';
import 'package:dio_project/core/network/api_client.dart';
import 'package:dio_project/domain/entity/product_entity.dart';
import 'package:dio_project/model/product_dto.dart';
import 'package:dio_project/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient;
  ProductRepositoryImpl(this._apiClient);
  @override
  Future<List<ProductEntity>> getProducts({CancelToken? cancelToken}) async {
    try {
      final response = await _apiClient.dio.get(
        'https://httpbin.org/delay/5', // '/products' is the correct path, 'https://httpbin.org/delay/5' to test the token cancel
        cancelToken: cancelToken,
      );
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
      if (error.error is AppException) {
        throw error.error!;
      }
      throw const UnknownException();
    } catch (error){
        throw const UnknownException('Failed to process server response.');
    }
  }
}