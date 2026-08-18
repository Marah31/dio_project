import 'package:dio/dio.dart';
import 'package:dio_project/core/network/interceptors/auth_interceptor.dart';
import 'package:dio_project/core/network/interceptors/error_interceptor.dart';
import 'package:dio_project/core/network/interceptors/logging_interceptor.dart';
import 'package:dio_project/core/network/interceptors/retry_interceptor.dart';
import 'package:dio_project/token_storage.dart';

class ApiClient {
  final Dio dio;
  final tokenStorage = TokenStorage();

  ApiClient()
    : dio = Dio(
      BaseOptions(
        baseUrl: 'https://yvoxycytyyqdjxevdbxg.supabase.co',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'apikey': 'sb_publishable_MyYPD0-IsQryAKqsfYDCwQ_qbSBY0tr', 
        },
      ),) {
          dio.interceptors.addAll([
          AuthInterceptor(dio: dio, tokenStorage: tokenStorage),
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
