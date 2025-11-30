class ProductRecommendation {
  final int id;
  final String name;

  ProductRecommendation({
    required this.id,
    required this.name,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Unknown Product",
    );
  }
}