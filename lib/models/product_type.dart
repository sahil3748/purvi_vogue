import 'package:cloud_firestore/cloud_firestore.dart';

class ProductTypeModel {
  final String id;
  final String subcategoryId;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final DateTime? createdAt;

  ProductTypeModel({
    required this.id,
    required this.subcategoryId,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'subcategoryId': subcategoryId,
      'name': name,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory ProductTypeModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProductTypeModel(
      id: doc.id,
      subcategoryId: data['subcategoryId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      thumbnailUrl: data['thumbnailUrl'],
      createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }
}
