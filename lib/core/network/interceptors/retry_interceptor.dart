import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor(this.dio, {this.maxRetries = 2});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isTimeout = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;

    final is5xx = err.response?.statusCode != null &&
        err.response!.statusCode! >= 500 &&
        err.response!.statusCode! < 600;

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if ((isTimeout || is5xx) && retryCount < maxRetries) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.reject(e);
      }
    }

    handler.next(err);
  }
}