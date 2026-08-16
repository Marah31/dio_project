class ProductEntity {
  final int id;
  final String name;
  final double price;
  final String description;
  final String categoryName;
  final double rating;
  final int ratingCount;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryName,
    required this.rating,
    required this.ratingCount
  });
}
