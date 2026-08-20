import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Dio refreshDio;
  final TokenStorage tokenStorage;
  final String refreshEndpointPath;

  Future<String?>? _refreshFuture;

  AuthInterceptor({
    required this.dio,
    required this.refreshDio,
    required this.tokenStorage,
    this.refreshEndpointPath =
        '/auth/v1/token?grant_type=refresh_token',
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        options.extra['sentWith'] = accessToken;
      }
      developer.log(
        'AUTH TOKEN ATTACHED: ${accessToken != null && accessToken.isNotEmpty}',
      );

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
        ),
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;

    developer.log(
      '${err.response?.statusCode} ${request.method} ${request.path}',
    );

    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    if (request.extra['isRetry'] == true) {
      developer.log(
        'Already retried: ${request.path}',
      );

      handler.next(err);
      return;
    }

    try {
      final sentToken = request.extra['sentWith'] as String?;

      final currentToken = await tokenStorage.getAccessToken();
      if (currentToken != null &&
          currentToken.isNotEmpty &&
          currentToken != sentToken) {
        developer.log(
          'Token already refreshed. '
          'Replaying without another refresh: ${request.path}',
        );

        await _retryRequest(
          request,
          currentToken,
          handler,
        );

        return;
      }
      if (_refreshFuture == null) {
        developer.log(
          'STARTING SINGLE REFRESH',
        );

        _refreshFuture = _doRefresh();

        _refreshFuture!.whenComplete(() {
          _refreshFuture = null;
        });
      } else {
        developer.log(
          'REFRESH ALREADY IN PROGRESS - WAITING',
        );
      }

      final newAccessToken = await _refreshFuture!;

      if (newAccessToken == null ||
          newAccessToken.isEmpty) {
        developer.log(
          'Refresh returned no access token',
        );

        handler.next(err);
        return;
      }

      await _retryRequest(
        request,
        newAccessToken,
        handler,
      );
    } catch (e, st) {
      developer.log(
        'Refresh failed',
        error: e,
        stackTrace: st,
      );

      handler.next(err);
    }
  }

  Future<String?> _doRefresh() async {
    final refreshToken =
        await tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      developer.log(
        'No refresh token available',
      );

      await tokenStorage.clearTokens();
      return null;
    }

    developer.log(
      'EXECUTING REFRESH HTTP CALL #1',
    );

    try {
      final response = await refreshDio.post(
        refreshEndpointPath,
        data: {
          'refresh_token': refreshToken,
        },
      );

      final newAccessToken =
          response.data['access_token'] as String?;

      final newRefreshToken =
          response.data['refresh_token'] as String?;

      if (newAccessToken == null ||
          newAccessToken.isEmpty) {
        throw Exception(
          'Refresh response did not contain access_token',
        );
      }

      if (newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        throw Exception(
          'Refresh response did not contain refresh_token',
        );
      }

      await tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      developer.log(
        'REFRESH SUCCESS - new tokens saved',
      );

      return newAccessToken;
    } catch (e, st) {
      developer.log(
        'REFRESH HTTP CALL FAILED',
        error: e,
        stackTrace: st,
      );

      await tokenStorage.clearTokens();

      rethrow;
    }
  }

  Future<void> _retryRequest(
    RequestOptions request,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      request.headers['Authorization'] =
          'Bearer $accessToken';

      request.extra['isRetry'] = true;

      developer.log(
        'REPLAYING ${request.method} ${request.path}',
      );

      final response = await dio.fetch(request);

      developer.log(
        'REPLAY SUCCESS ${request.method} ${request.path} '
        '[${response.statusCode}]',
      );

      handler.resolve(response);
    } on DioException catch (e) {
      developer.log(
        'REPLAY FAILED ${request.path} '
        '[${e.response?.statusCode}]',
      );

      handler.next(e);
    }
  }
}