import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra['startTime'] = DateTime.now();
    print(
      'REQUEST[${options.method}] => PATH: ${options.path}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final startTime = response.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : 'N/A';

    print(
      'RESPONSE[${response.statusCode}] DURATION: $duration => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : 'N/A';

    final centralError = err.error; 
    final displayError = centralError != null 
        ? centralError.toString() 
        : (err.response?.statusCode?.toString() ?? err.type.name);

    print(
      'ERROR[$displayError] DURATION: $duration => PATH: ${err.requestOptions.path}',
    );

    super.onError(err, handler);
  }
}