import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String title;

  final String imageUrl;
  final String ctaText;

  final String linkCategoryId;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.ctaText,
    required this.linkCategoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'ctaText': ctaText,
      'linkCategoryId': linkCategoryId,
    };
  }

  factory BannerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ctaText: data['ctaText'] ?? '',
      linkCategoryId: data['linkCategoryId'] ?? '',
    );
  }
}
