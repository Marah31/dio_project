import 'package:dio/dio.dart';
import '../../../token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final String refreshEndpointPath;

  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    this.refreshEndpointPath = '/auth/v1/token?grant_type=refresh_token',
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && err.requestOptions.extra['isRetry'] != true) {
      try {
        final refreshToken = await tokenStorage.getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) {
          await tokenStorage.clearTokens();
          return handler.next(err);
        }

        final refreshResponse = await dio.post(
          refreshEndpointPath,
          data: {'refresh_token': refreshToken},
          options: Options(
            extra: {'isRetry': true}, 
          ),
        );

        final newAccessToken = refreshResponse.data['access_token'];
        final newRefreshToken = refreshResponse.data['refresh_token'];
        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        requestOptions.extra['isRetry'] = true;

        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        await tokenStorage.clearTokens();
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}