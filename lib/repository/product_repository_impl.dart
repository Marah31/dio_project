import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:dio_project/core/error/app_exception.dart';
import 'package:dio_project/core/network/api_client.dart';
import 'package:dio_project/domain/entity/product_entity.dart';
import 'package:dio_project/model/product_dto.dart';
import 'package:dio_project/repository/product_repository.dart';
import 'dart:developer' as developer;

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient;
  ProductRepositoryImpl(this._apiClient);
  @override
  Future<List<ProductEntity>> getProducts({CancelToken? cancelToken}) async {
    try {
      final response = await _apiClient.dio.get(
        '/rest/v1/items?select=*',
        cancelToken: cancelToken,
      );
      final data = response.data;
      return await Isolate.run(() => _parseProducts(data));
    } on DioException catch (error, stackTrace) {
      if (error.error is AppException) {
        final appException = error.error as AppException;
        developer.log(
          'AppException in getProducts: ${appException.runtimeType}',
          error: error,
          stackTrace: stackTrace,
        );
        throw appException;
      }

      developer.log(
        'Unmapped Dio error in getProducts: ${error.message}',
        error: error,
        stackTrace: stackTrace,
      );
      throw const UnknownException();
    } catch (error, stackTrace) {
      developer.log(
        'Non-Dio error occurred in getProducts: $error',
        error: error,
        stackTrace: stackTrace,
      );
      throw const UnknownException('Failed to process server response.');
    }
  }
}
List<ProductEntity> _parseProducts(dynamic data) {
  final List rawList = data as List;
  return rawList
      .map(
        (json) => ProductDto.fromJson(json as Map<String, dynamic>).toEntity(),
      )
      .toList();
}