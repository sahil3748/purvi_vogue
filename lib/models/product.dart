import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final Map<String, num?>? priceRange; // {'min': 1000, 'max': 1500}
  final String categoryId;
  final String subCategoryId;
  final List<String> gender; // ["Women", "Men", "Unisex"]
  final List<String> imageUrls;
  final List<String> tags;
  final String? material; // e.g., "92.5 Sterling Silver"
  final String? weight; // optional
  final String? dimensions; // optional
  final String? color;
  final String? careInstructions;
  final bool inStock;
  final bool isFeatured;
  final String? styleTips; // optional
  final List<String> occasion; // ["Festive", "Casual", "Wedding"]
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.priceRange,
    required this.categoryId,
    required this.subCategoryId,
    required this.gender,
    this.imageUrls = const [],
    this.tags = const [],
    this.material,
    this.weight,
    this.dimensions,
    this.color,
    this.careInstructions,
    this.inStock = true,
    this.isFeatured = false,
    this.styleTips,
    this.occasion = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'priceRange': priceRange,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'gender': gender,
      'imageUrls': imageUrls,
      'tags': tags,
      'material': material,
      'weight': weight,
      'dimensions': dimensions,
      'color': color,
      'careInstructions': careInstructions,
      'inStock': inStock,
      'isFeatured': isFeatured,
      'styleTips': styleTips,
      'occasion': occasion,
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
      subCategoryId: data['subCategoryId'] ?? '',
      gender: (data['gender'] as List<dynamic>? ?? []).cast<String>(),
      imageUrls: (data['imageUrls'] as List<dynamic>? ?? []).cast<String>(),
      tags: (data['tags'] as List<dynamic>? ?? []).cast<String>(),
      material: data['material'],
      weight: data['weight'],
      dimensions: data['dimensions'],
      color: data['color'],
      careInstructions: data['careInstructions'],
      inStock: data['inStock'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      styleTips: data['styleTips'],
      occasion: (data['occasion'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }
}


