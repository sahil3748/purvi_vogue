import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final Map<String, num?>? priceRange; // {'min': 1000, 'max': 1500}
  final String categoryId;
  final String? subCategory;
  final List<String> imageUrls;
  final List<String> tags;
  final bool isFeatured;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.priceRange,
    required this.categoryId,
    this.subCategory,
    this.imageUrls = const [],
    this.tags = const [],
    this.isFeatured = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'priceRange': priceRange,
      'categoryId': categoryId,
      'subCategory': subCategory,
      'imageUrls': imageUrls,
      'tags': tags,
      'isFeatured': isFeatured,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      priceRange: (data['priceRange'] is Map<String, dynamic>)
          ? (data['priceRange'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as num?))
          : null,
      categoryId: data['categoryId'] ?? '',
      subCategory: data['subCategory'],
      imageUrls: (data['imageUrls'] as List<dynamic>? ?? []).cast<String>(),
      tags: (data['tags'] as List<dynamic>? ?? []).cast<String>(),
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }
}


