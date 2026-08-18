
import 'package:dio_project/domain/entity/product_entity.dart';

// class RatingDto {
//   final double rate;
//   final int count;

//   RatingDto({required this.rate, required this.count});

//   factory RatingDto.fromJson(Map<String, dynamic> json) {
//     return RatingDto(
//       rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
//       count: json['count'] as int? ?? 0,
//     );
//   }
// }

class ProductDto {
  final int id;
  final String name;
  final double price;
  final String description;
  final String categoryName;
  final String image;
  //final RatingDto? rating;

  ProductDto({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryName,
    required this.image,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int? ?? 0,
      name: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      categoryName: json['category'] as String? ?? '',
      // rating: json['rating'] != null
      //     ? RatingDto.fromJson(json['rating'] as Map<String, dynamic>)
      //     : null,
      image: json['image'] as String? ?? ''
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      description: description,
      categoryName: categoryName,
      // rating: rating?.rate ?? 0.0,
      // ratingCount: rating?.count ?? 0,
      image: image
    );
  }
}