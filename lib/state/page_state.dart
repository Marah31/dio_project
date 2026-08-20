import 'package:dio_project/domain/entity/product_entity.dart';
import 'package:dio_project/state/product_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageState {
  final List<ProductEntity> products;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;

  PageState({
    this.products = const [],
    this.page = 1,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  PageState copyWith({
    List<ProductEntity>? products,
    int? page,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return PageState(
      products: products ?? this.products,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PageNotifier extends Notifier<PageState> {
  String _currentQuery = '';
  
  @override
  PageState build() {
    Future.microtask(() => fetchNextPage());
    return PageState();
  }

  Future<void> searchProducts(String query) async {
    _currentQuery = query;
    state = PageState(isLoadingMore: true);

    try {
      final repository = ref.read(productRepositoryProvider);
      final newItems = await repository.getProducts(
        page: 1,
        limit: 20,
        searchQuery: _currentQuery,
      );

      state = state.copyWith(
        products: newItems,
        page: 2,
        isLoadingMore: false,
        hasMore: newItems.length == 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repository = ref.read(productRepositoryProvider);
      final newItems = await repository.getProducts(
        page: state.page,
        limit: 20,
        searchQuery: _currentQuery,
      );

      state = state.copyWith(
        products: [...state.products, ...newItems],
        page: state.page + 1,
        isLoadingMore: false,
        hasMore: newItems.length == 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final previousProducts = state.products;
    state = state.copyWith(
      products: state.products.map((product) {
        if (product.id == productId) {
          return product.copyWith(isFavorite: !product.isFavorite);
        }

        return product;
      }).toList(),
    );

    final updatedProduct = state.products.firstWhere((p) => p.id == productId);

    try {
      final repository = ref.read(productRepositoryProvider);

      await repository.updateFavorite(
        productId: productId,
        isFavorite: updatedProduct.isFavorite,
        forceFailure: true,
      );
    } catch (e) {
      state = state.copyWith(products: previousProducts);
      rethrow;
    }
  }
}

final pageProvider = NotifierProvider<PageNotifier, PageState>(
  PageNotifier.new,
);