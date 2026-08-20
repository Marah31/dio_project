import 'package:dio/dio.dart';
import 'package:dio_project/core/network/interceptors/auth_interceptor.dart';
import 'package:dio_project/core/network/interceptors/error_interceptor.dart';
import 'package:dio_project/core/network/interceptors/logging_interceptor.dart';
import 'package:dio_project/core/network/interceptors/retry_interceptor.dart';
import 'package:dio_project/core/storage/token_storage.dart';

class ApiClient {
  final Dio dio;
  static const String _baseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );
  static const String _apiKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  final tokenStorage = TokenStorage();
  final Dio refreshDio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json', 'apikey': _apiKey},
    ),
  );
  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'apikey': _apiKey,
          },
        ),
      ) {
    dio.interceptors.addAll([
      AuthInterceptor(
        dio: dio,
        refreshDio: refreshDio,
        tokenStorage: tokenStorage,
      ),
      RetryInterceptor(dio),
      ErrorMappingInterceptor(),
      LoggingInterceptor(),
    ]);
  }
  void dispose() => dio.close(force: true);
}
