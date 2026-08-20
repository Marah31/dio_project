import 'package:dio_project/domain/entity/product_entity.dart';
class ProductDto {
  final int id;
  final String name;
  final double price;
  final String description;
  final String categoryName;
  final String image;
  final bool isFavorite;

  ProductDto({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryName,
    required this.image,
    required this.isFavorite
  });

  factory ProductDto.fromJson(Map<String, dynamic> json, {isFavorite = false}) {
    return ProductDto(
      id: json['id'] as int? ?? 0,
      name: (json['name'] ?? json['title']) as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      categoryName:
          (json['category_name'] ?? json['categoryName']) as String? ?? '',
      image: json['image'] as String? ?? '',
      isFavorite: isFavorite,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      description: description,
      categoryName: categoryName,
      image: image,
      isFavorite: isFavorite,
    );
  }
}