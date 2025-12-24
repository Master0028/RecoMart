class ProductRecommendation {
  final String id;
  final String name;

  ProductRecommendation({
    required this.id,
    required this.name,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Product',
    );
  }
}
