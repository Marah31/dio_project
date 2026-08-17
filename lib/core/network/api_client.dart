import 'package:dio/dio.dart';
import 'package:dio_project/core/network/interceptors/error_interceptor.dart';
import 'package:dio_project/core/network/interceptors/logging_interceptor.dart';
import 'package:dio_project/core/network/interceptors/retry_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
    : dio = Dio(
      BaseOptions(
        baseUrl: 'https://fakestoreapi.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),) {
          dio.interceptors.addAll([
          RetryInterceptor(dio),
          ErrorMappingInterceptor(),
          LoggingInterceptor(),
          ]);  
        }
    // https://httpbin.org/delay/5
    // url for products: https://fakestoreapi.com
    // url for different request errors: https://httpstat.us/
  void dispose() => dio.close(force: true);
}
