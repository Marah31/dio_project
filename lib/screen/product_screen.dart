import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:dio_project/domain/entity/product_entity.dart';
import 'package:dio_project/state/auth_notifier.dart';
import 'package:dio_project/state/auth_provider.dart';
import 'package:dio_project/state/page_state.dart';
import 'package:dio_project/state/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class ProductUI extends ConsumerStatefulWidget {
  const ProductUI({super.key});

  @override
  ConsumerState<ProductUI> createState() => _ProductUIState();
}

class _ProductUIState extends ConsumerState<ProductUI> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(pageProvider.notifier).fetchNextPage();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(pageProvider.notifier).searchProducts(query);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageState = ref.watch(pageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
        backgroundColor: const Color(0xFFF7F7FA),
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search product..',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(pageState)),
            ElevatedButton(
              onPressed: () {
                testConcurrent401s(ref);
              },
              child: const Text('Test concurrency case'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PageState pageState) {
    if (pageState.products.isEmpty && pageState.isLoadingMore) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }

    if (pageState.products.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: pageState.products.length + (pageState.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == pageState.products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
          );
        }

        final product = pageState.products[index];
        return _ProductCard(key: ValueKey(product.id), product: product);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildProductImage(product.image),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _CategoryChip(label: product.categoryName),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 24, 113, 173),
                    ),
                  ),
                  FavoriteButton(
                    productId: product.id,
                    isFavorite: product.isFavorite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A6CF7),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFFB0B0BE)),
          SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B6B76),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: Color(0xFFE05C5C),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sorry, try again later :/',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B6B76)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(productsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProductImage(String imageUrl) {
  if (imageUrl.isEmpty) {
    return const Icon(
      Icons.shopping_bag_outlined,
      color: Color(0xFFB0B0BE),
      size: 28,
    );
  }

  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => const Icon(
      Icons.broken_image_outlined,
      color: Color(0xFFB0B0BE),
      size: 28,
    ),
  );
}

Future<void> testConcurrent401s(WidgetRef ref) async {
  final apiClient = ref.read(apiClientProvider);
  final tokenStorage = ref.read(tokenStorageProvider);

  final realRefreshToken = await tokenStorage.getRefreshToken();

  if (realRefreshToken == null || realRefreshToken.isEmpty) {
    developer.log('Please log in through the UI first!');
    return;
  }

  await tokenStorage.saveTokens(
    accessToken: 'EXPIRED_OR_INVALID_JWT_TOKEN',
    refreshToken: realRefreshToken,
  );

  developer.log(
    '\n--- STARTING CONCURRENCY TEST: FIRING 3 SIMULTANEOUS REQUESTS ---',
  );

  await Future.wait([
    apiClient.dio.get('/rest/v1/items?select=*'),
    apiClient.dio.get('/rest/v1/items?select=*'),
    apiClient.dio.get('/rest/v1/items?select=*'),
  ]).catchError((err) {
    developer.log('Test finished: $err');
    return <Response>[];
  });
}

class FavoriteButton extends ConsumerWidget {
  final int productId;
  final bool isFavorite;

  const FavoriteButton({
    super.key,
    required this.productId,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: () async {
        try {
          await ref.read(pageProvider.notifier).toggleFavorite(productId);
        } catch (_) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Favorite update failed. Your change was reverted.',
                ),
              ),
            );
        }
      },
    );
  }
}
