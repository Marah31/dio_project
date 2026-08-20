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
  Future<List<ProductEntity>> getProducts({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    CancelToken? cancelToken,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final queryParams = <String, dynamic>{
        'select': '*',
        'limit': limit,
        'offset': offset,
        'order': 'id.asc',
      };

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryParams['name'] = 'ilike.*${searchQuery.trim()}*';
      }

      final response = await _apiClient.dio.get(
        '/rest/v1/items',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );
      //developer.log('RAW SUPABASE RESPONSE: ${response.data}');

      final favoritesResponse = await _apiClient.dio.get(
        '/rest/v1/favorites',
        queryParameters: {'select': 'item_id'},
        cancelToken: cancelToken,
      );

      final favoriteIds = (favoritesResponse.data as List)
          .map((favorite) => favorite['item_id'] as int)
          .toSet();

      final data = response.data;
      return await Isolate.run(() => _parseProducts(data, favoriteIds));
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

  @override
  Future<void> updateFavorite({
    required int productId,
    required bool isFavorite,
    bool forceFailure = true,
  }) async {
    if (forceFailure) {
      developer.log('ForceFailure is $forceFailure');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      developer.log('Forced favorite update failure');
      throw Exception('Forced favorite update failure');
    }

    if (isFavorite) {
      try {
        await _apiClient.dio.post(
          '/rest/v1/favorites',
          data: {'item_id': productId},
          options: Options(headers: {'Prefer': 'return=representation'}),
        );
      } on DioException catch (e) {
        developer.log('FAVORITE ERROR STATUS: ${e.response?.statusCode}');

        developer.log('FAVORITE ERROR DATA: ${e.response?.data}');

        rethrow;
      }
    } else {
      await _apiClient.dio.delete(
        '/rest/v1/favorites',
        queryParameters: {'item_id': 'eq.$productId'},
      );
    }
  }
}

List<ProductEntity> _parseProducts(dynamic data, Set<int> favoriteIds) {
  final List rawList = data as List;

  return rawList.map((json) {
    final map = json as Map<String, dynamic>;
    final productId = map['id'] as int? ?? 0;

    return ProductDto.fromJson(
      map,
      isFavorite: favoriteIds.contains(productId),
    ).toEntity();
  }).toList();
}
