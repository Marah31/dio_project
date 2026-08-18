import 'package:dio/dio.dart';
import 'package:dio_project/token_storage.dart';

class AuthRepositoryImpl {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.dio, this.tokenStorage);

  // Future<void> login(String email, String password) async {
  //   final response = await dio.post(
  //     '/auth/v1/token?grant_type=password',
  //     data: {
  //       'email': email,
  //       'password': password,
  //     },
  //   );

  //   final accessToken = response.data['access_token'];
  //   final refreshToken = response.data['refresh_token'];

  //   await tokenStorage.saveTokens(
  //     accessToken: accessToken,
  //     refreshToken: refreshToken,
  //   );
  // }
  Future<void> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/v1/token?grant_type=password',
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      print('❌ [Login Error]: ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }
}