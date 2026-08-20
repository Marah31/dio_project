import 'package:dio/dio.dart';
import 'package:dio_project/core/storage/token_storage.dart';
import 'dart:developer' as developer;
class AuthRepositoryImpl {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.dio, this.tokenStorage);

  Future<void> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/v1/token?grant_type=password',
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      developer.log('Saved Access Token.');
      developer.log('Saved Refresh Token.');
    } on DioException catch (e) {
      developer.log('[Login Error]: ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }
}
