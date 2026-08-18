import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'product_provider.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthController extends AsyncNotifier<AuthStatus> {
  @override
  Future<AuthStatus> build() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      return AuthStatus.authenticated;
    }
    return AuthStatus.unauthenticated;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(email, password);
      ref.invalidate(productsProvider);
      return AuthStatus.authenticated;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    ref.invalidate(productsProvider);
    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthStatus>(() {
  return AuthController();
});