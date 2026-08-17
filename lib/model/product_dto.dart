
import 'package:dio_project/domain/entity/product_entity.dart';

class RatingDto {
  final double rate;
  final int count;

  RatingDto({required this.rate, required this.count});

  factory RatingDto.fromJson(Map<String, dynamic> json) {
    return RatingDto(
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
    );
  }
}

class ProductDto {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final RatingDto? rating;

  ProductDto({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    this.rating,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      rating: json['rating'] != null
          ? RatingDto.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: title,
      price: price,
      description: description,
      categoryName: category,
      rating: rating?.rate ?? 0.0,
      ratingCount: rating?.count ?? 0,
    );
  }
}