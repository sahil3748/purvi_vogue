import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory CategoryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }
}


