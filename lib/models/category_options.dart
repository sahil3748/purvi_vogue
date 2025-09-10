import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryOptionsModel {
  final String id;
  final String categoryId;
  final List<String> materials;
  final List<String> sizes;
  final List<String> weights;
  final List<String> genders;
  final List<String> colors;
  final List<String> occasions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryOptionsModel({
    required this.id,
    required this.categoryId,
    this.materials = const [],
    this.sizes = const [],
    this.weights = const [],
    this.genders = const [],
    this.colors = const [],
    this.occasions = const [],
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'materials': materials,
      'sizes': sizes,
      'weights': weights,
      'genders': genders,
      'colors': colors,
      'occasions': occasions,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory CategoryOptionsModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CategoryOptionsModel(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      materials: (data['materials'] as List<dynamic>? ?? []).cast<String>(),
      sizes: (data['sizes'] as List<dynamic>? ?? []).cast<String>(),
      weights: (data['weights'] as List<dynamic>? ?? []).cast<String>(),
      genders: (data['genders'] as List<dynamic>? ?? []).cast<String>(),
      colors: (data['colors'] as List<dynamic>? ?? []).cast<String>(),
      occasions: (data['occasions'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: (data['updatedAt'] is Timestamp) ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  CategoryOptionsModel copyWith({
    String? id,
    String? categoryId,
    List<String>? materials,
    List<String>? sizes,
    List<String>? weights,
    List<String>? genders,
    List<String>? colors,
    List<String>? occasions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryOptionsModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      materials: materials ?? this.materials,
      sizes: sizes ?? this.sizes,
      weights: weights ?? this.weights,
      genders: genders ?? this.genders,
      colors: colors ?? this.colors,
      occasions: occasions ?? this.occasions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get all options for a specific type
  List<String> getOptionsForType(String type) {
    switch (type.toLowerCase()) {
      case 'materials':
        return materials;
      case 'sizes':
        return sizes;
      case 'weights':
        return weights;
      case 'genders':
        return genders;
      case 'colors':
        return colors;
      case 'occasions':
        return occasions;
      default:
        return [];
    }
  }

  // Helper method to check if options exist for a type
  bool hasOptionsForType(String type) {
    return getOptionsForType(type).isNotEmpty;
  }
}
