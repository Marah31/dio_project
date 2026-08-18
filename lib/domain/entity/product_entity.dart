import 'package:freezed_annotation/freezed_annotation.dart';
part 'product_entity.freezed.dart';

@freezed
abstract class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required int id,
    required String name,
    required double price,
    required String description,
    required String categoryName,
    // required double rating,
    // required int ratingCount,
    required String image,
  }) = _ProductEntity;

  const ProductEntity._();
}
