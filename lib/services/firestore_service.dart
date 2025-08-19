import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Categories
  Stream<List<CategoryModel>> watchCategories() {
    return _db
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CategoryModel.fromDoc(d)).toList());
  }

  Future<String> addCategory({required String name, String? description}) async {
    final doc = await _db.collection('categories').add({
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection('categories').doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }

  // Products
  Stream<List<ProductModel>> watchProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Future<String> addProduct(ProductModel product) async {
    final doc = await _db.collection('products').add(product.toMap());
    return doc.id;
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // Admins
  Future<bool> isAdminUid(String uid) async {
    final doc = await _db.collection('admins').doc(uid).get();
    return doc.exists;
  }
}


