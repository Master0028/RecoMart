class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.imageUrl,
  });

  /// Chuyển từ Firestore hoặc JSON thành CategoryModel
  factory CategoryModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CategoryModel(
      id: (data['id'] ?? 0).toInt(),
      name: data['name'] ?? '',
      description: data['description'],
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  /// Chuyển ngược lại sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
