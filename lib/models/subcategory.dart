import 'package:cloud_firestore/cloud_firestore.dart';

class SubcategoryModel {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final String? thumbnailUrl;

  SubcategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory SubcategoryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SubcategoryModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      thumbnailUrl: data['thumbnailUrl'],
    );
  }
}
