import 'package:dio/dio.dart';
import '../../error/app_exception.dart';

class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mappedException = _mapException(err);
    handler.next(
      err.copyWith(error: mappedException),
    );
  }

  AppException _mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        if (status == 401 || status == 403) {
          return const UnauthorizedException();
        } else if (status != null && status >= 500) {
          return ServerException(status);
        }
        return ServerException(status, 'Server returned error $status');

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled');

      default:
        return UnknownException(err.message ?? 'Unknown network error');
    }
  }
}