import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String? longDescription;
  final Map<String, num?>? priceRange; // {'min': 1000, 'max': 1500}
  final String categoryId;
  final String subCategoryId;
  final List<String> productTypes; // Multiple product types
  final List<String> gender; // ["Women", "Men", "Unisex"]
  final List<String> imageUrls; // Multiple images
  final List<String> tags;
  final String? material; // e.g., "92.5 Sterling Silver"
  final String? weight; // optional
  final String? size; // Size information
  final String? dimensions; // optional
  final List<String> colors; // Multiple colors
  final String? careInstructions;
  final bool isAvailable;
  final bool inStock;
  final bool isBestSeller;
  final bool isFeatured;
  final String? styleTips; // optional
  final List<String> occasion; // ["Festive", "Casual", "Wedding"]
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.longDescription,
    this.priceRange,
    required this.categoryId,
    required this.subCategoryId,
    this.productTypes = const [],
    required this.gender,
    this.imageUrls = const [],
    this.tags = const [],
    this.material,
    this.weight,
    this.size,
    this.dimensions,
    this.colors = const [],
    this.careInstructions,
    this.isAvailable = true,
    this.inStock = true,
    this.isBestSeller = false,
    this.isFeatured = false,
    this.styleTips,
    this.occasion = const [],
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'longDescription': longDescription,
      'priceRange': priceRange,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'productTypes': productTypes,
      'gender': gender,
      'imageUrls': imageUrls,
      'tags': tags,
      'material': material,
      'weight': weight,
      'size': size,
      'dimensions': dimensions,
      'colors': colors,
      'careInstructions': careInstructions,
      'isAvailable': isAvailable,
      'inStock': inStock,
      'isBestSeller': isBestSeller,
      'isFeatured': isFeatured,
      'styleTips': styleTips,
      'occasion': occasion,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      longDescription: data['longDescription'],
      priceRange: (data['priceRange'] is Map<String, dynamic>)
          ? (data['priceRange'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as num?))
          : null,
      categoryId: data['categoryId'] ?? '',
      subCategoryId: data['subCategoryId'] ?? '',
      productTypes: (data['productTypes'] as List<dynamic>? ?? []).cast<String>(),
      gender: (data['gender'] as List<dynamic>? ?? []).cast<String>(),
      imageUrls: (data['imageUrls'] as List<dynamic>? ?? []).cast<String>(),
      tags: (data['tags'] as List<dynamic>? ?? []).cast<String>(),
      material: data['material'],
      weight: data['weight'],
      size: data['size'],
      dimensions: data['dimensions'],
      colors: (data['colors'] as List<dynamic>? ?? []).cast<String>(),
      careInstructions: data['careInstructions'],
      isAvailable: data['isAvailable'] ?? true,
      inStock: data['inStock'] ?? true,
      isBestSeller: data['isBestSeller'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      styleTips: data['styleTips'],
      occasion: (data['occasion'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: (data['updatedAt'] is Timestamp) ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }
}


