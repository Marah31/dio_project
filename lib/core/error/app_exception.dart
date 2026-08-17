import 'package:flutter/foundation.dart';

@immutable
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized access.']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(this.statusCode, [super.message = 'Server error occurred.']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}