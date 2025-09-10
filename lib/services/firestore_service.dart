import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/models/product_type.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/banner.dart';
import 'package:purvi_vogue/models/admin.dart';
import 'package:purvi_vogue/models/category_options.dart';
import 'package:purvi_vogue/config/database_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Categories
  Stream<List<CategoryModel>> watchCategories() {
    return _db
        .collection(DatabaseConstants.categoriesCollection)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CategoryModel.fromDoc(d)).toList());
  }

  Future<List<CategoryModel>> getCategories() async {
    final snap = await _db
        .collection(DatabaseConstants.categoriesCollection)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .get();
    return snap.docs.map((d) => CategoryModel.fromDoc(d)).toList();
  }

  Future<String> addCategory(CategoryModel category) async {
    final doc = await _db.collection(DatabaseConstants.categoriesCollection).add(category.toMap());
    return doc.id;
  }

  Future<String> addCategoryWithParams({required String name, String? description, String? thumbnailUrl}) async {
    final doc = await _db.collection(DatabaseConstants.categoriesCollection).add({
      DatabaseConstants.nameField: name,
      DatabaseConstants.descriptionField: description,
      DatabaseConstants.thumbnailUrlField: thumbnailUrl,
      DatabaseConstants.createdAtField: FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection(DatabaseConstants.categoriesCollection).doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection(DatabaseConstants.categoriesCollection).doc(id).delete();
  }

  // Subcategories
  Stream<List<SubcategoryModel>> watchSubcategories() {
    return _db
        .collection(DatabaseConstants.subcategoriesCollection)
        .snapshots()
        .map((snap) => snap.docs.map((d) => SubcategoryModel.fromDoc(d)).toList());
  }

  Stream<List<SubcategoryModel>> watchSubcategoriesByCategory(String categoryId) {
    return _db
        .collection(DatabaseConstants.subcategoriesCollection)
        .where(DatabaseConstants.categoryIdField, isEqualTo: categoryId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => SubcategoryModel.fromDoc(d)).toList());
  }

  Future<List<SubcategoryModel>> getSubcategories() async {
    final snap = await _db
        .collection(DatabaseConstants.subcategoriesCollection)
        .get();
    return snap.docs.map((d) => SubcategoryModel.fromDoc(d)).toList();
  }

  Future<String> addSubcategory(SubcategoryModel subcategory) async {
    final doc = await _db.collection(DatabaseConstants.subcategoriesCollection).add(subcategory.toMap());
    return doc.id;
  }

  Future<void> updateSubcategory(SubcategoryModel subcategory) async {
    await _db.collection(DatabaseConstants.subcategoriesCollection).doc(subcategory.id).update(subcategory.toMap());
  }

  Future<void> deleteSubcategory(String id) async {
    await _db.collection(DatabaseConstants.subcategoriesCollection).doc(id).delete();
  }

  // Product Types
  Stream<List<ProductTypeModel>> watchProductTypes() {
    return _db
        .collection('productTypes')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductTypeModel.fromDoc(d)).toList());
  }

  Stream<List<ProductTypeModel>> watchProductTypesBySubcategory(String subcategoryId) {
    return _db
        .collection('productTypes')
        .where('subcategoryId', isEqualTo: subcategoryId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductTypeModel.fromDoc(d)).toList());
  }

  Future<List<ProductTypeModel>> getProductTypes() async {
    final snap = await _db
        .collection('productTypes')
        .get();
    return snap.docs.map((d) => ProductTypeModel.fromDoc(d)).toList();
  }

  Future<List<ProductTypeModel>> getProductTypesBySubcategory(String subcategoryId) async {
    final snap = await _db
        .collection('productTypes')
        .where('subcategoryId', isEqualTo: subcategoryId)
        .get();
    return snap.docs.map((d) => ProductTypeModel.fromDoc(d)).toList();
  }

  Future<String> addProductType(ProductTypeModel productType) async {
    final doc = await _db.collection('productTypes').add(productType.toMap());
    return doc.id;
  }

  Future<void> updateProductType(ProductTypeModel productType) async {
    await _db.collection('productTypes').doc(productType.id).update(productType.toMap());
  }

  Future<void> deleteProductType(String id) async {
    await _db.collection('productTypes').doc(id).delete();
  }

  // Products
  Stream<List<ProductModel>> watchProducts() {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> watchProductsByCategory(String categoryId) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.categoryIdField, isEqualTo: categoryId)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> watchProductsBySubcategory(String subcategoryId) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.subCategoryIdField, isEqualTo: subcategoryId)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> watchProductsByGender(String gender) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.genderField, arrayContains: gender)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> watchFeaturedProducts() {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.isFeaturedField, isEqualTo: true)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> watchInStockProducts() {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.inStockField, isEqualTo: true)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Future<List<ProductModel>> getProducts() async {
    final snap = await _db
        .collection(DatabaseConstants.productsCollection)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .get();
    return snap.docs.map((d) => ProductModel.fromDoc(d)).toList();
  }

  // Dashboard count methods
  Future<int> getCategoriesCount() async {
    final snap = await _db.collection(DatabaseConstants.categoriesCollection).get();
    return snap.docs.length;
  }

  Future<int> getSubcategoriesCount() async {
    final snap = await _db.collection(DatabaseConstants.subcategoriesCollection).get();
    return snap.docs.length;
  }

  Future<int> getProductTypesCount() async {
    final snap = await _db.collection('productTypes').get();
    return snap.docs.length;
  }

  Future<int> getProductsCount() async {
    final snap = await _db.collection(DatabaseConstants.productsCollection).get();
    return snap.docs.length;
  }

  Future<int> getInStockProductsCount() async {
    final snap = await _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.inStockField, isEqualTo: true)
        .get();
    return snap.docs.length;
  }

  Future<int> getFeaturedProductsCount() async {
    final snap = await _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.isFeaturedField, isEqualTo: true)
        .get();
    return snap.docs.length;
  }

  Future<String> addProduct(ProductModel product) async {
    final doc = await _db.collection(DatabaseConstants.productsCollection).add(product.toMap());
    return doc.id;
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection(DatabaseConstants.productsCollection).doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection(DatabaseConstants.productsCollection).doc(id).delete();
  }

  // Banners
  Stream<List<BannerModel>> watchBanners() {
    return _db
        .collection(DatabaseConstants.bannersCollection)
        .snapshots()
        .map((snap) => snap.docs.map((d) => BannerModel.fromDoc(d)).toList());
  }

  Future<String> addBanner(BannerModel banner) async {
    final doc = await _db.collection(DatabaseConstants.bannersCollection).add(banner.toMap());
    return doc.id;
  }

  Future<void> updateBanner(BannerModel banner) async {
    await _db.collection(DatabaseConstants.bannersCollection).doc(banner.id).update(banner.toMap());
  }

  Future<void> deleteBanner(String id) async {
    await _db.collection(DatabaseConstants.bannersCollection).doc(id).delete();
  }

  // Admins
  Future<bool> isAdminUid(String uid) async {
    final doc = await _db.collection(DatabaseConstants.adminsCollection).doc(uid).get();
    return doc.exists;
  }

  Future<AdminModel?> getAdmin(String uid) async {
    final doc = await _db.collection(DatabaseConstants.adminsCollection).doc(uid).get();
    if (doc.exists) {
      return AdminModel.fromDoc(doc);
    }
    return null;
  }

  Future<String> addAdmin(AdminModel admin) async {
    final doc = await _db.collection(DatabaseConstants.adminsCollection).doc(admin.uid).set(admin.toMap());
    return admin.uid;
  }

  Future<void> updateAdmin(AdminModel admin) async {
    await _db.collection(DatabaseConstants.adminsCollection).doc(admin.uid).update(admin.toMap());
  }

  Future<void> deleteAdmin(String uid) async {
    await _db.collection(DatabaseConstants.adminsCollection).doc(uid).delete();
  }

  // Search and Filter Methods
  Stream<List<ProductModel>> searchProducts(String query) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.nameField, isGreaterThanOrEqualTo: query)
        .where(DatabaseConstants.nameField, isLessThan: query + '\uf8ff')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> filterProductsByTags(List<String> tags) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.tagsField, arrayContainsAny: tags)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> filterProductsByOccasion(List<String> occasions) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where(DatabaseConstants.occasionField, arrayContainsAny: occasions)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  // New methods for enhanced product filtering
  Stream<List<ProductModel>> watchBestSellerProducts() {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where('isBestSeller', isEqualTo: true)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> watchAvailableProducts() {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where('isAvailable', isEqualTo: true)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> filterProductsByProductTypes(List<String> productTypes) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where('productTypes', arrayContainsAny: productTypes)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> filterProductsByColors(List<String> colors) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where('colors', arrayContainsAny: colors)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> filterProductsByMaterial(String material) {
    return _db
        .collection(DatabaseConstants.productsCollection)
        .where('material', isEqualTo: material)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Future<List<ProductModel>> getProductsByProductType(String productType) async {
    final snap = await _db
        .collection(DatabaseConstants.productsCollection)
        .where('productTypes', arrayContains: productType)
        .orderBy(DatabaseConstants.createdAtField, descending: true)
        .get();
    return snap.docs.map((d) => ProductModel.fromDoc(d)).toList();
  }

  // Category Options
  Stream<List<CategoryOptionsModel>> watchCategoryOptions() {
    return _db
        .collection('categoryOptions')
        .snapshots()
        .map((snap) => snap.docs.map((d) => CategoryOptionsModel.fromDoc(d)).toList());
  }

  Future<CategoryOptionsModel?> getCategoryOptions(String categoryId) async {
    final snap = await _db
        .collection('categoryOptions')
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();
    
    if (snap.docs.isNotEmpty) {
      return CategoryOptionsModel.fromDoc(snap.docs.first);
    }
    return null;
  }

  Future<String> addCategoryOptions(CategoryOptionsModel options) async {
    final doc = await _db.collection('categoryOptions').add(options.toMap());
    return doc.id;
  }

  Future<void> updateCategoryOptions(CategoryOptionsModel options) async {
    await _db.collection('categoryOptions').doc(options.id).update(options.toMap());
  }

  Future<void> deleteCategoryOptions(String id) async {
    await _db.collection('categoryOptions').doc(id).delete();
  }

  Future<void> deleteCategoryOptionsByCategory(String categoryId) async {
    final snap = await _db
        .collection('categoryOptions')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // Helper method to get all available options for a category
  Future<Map<String, List<String>>> getAllOptionsForCategory(String categoryId) async {
    final options = await getCategoryOptions(categoryId);
    if (options != null) {
      return {
        'materials': options.materials,
        'sizes': options.sizes,
        'weights': options.weights,
        'genders': options.genders,
        'colors': options.colors,
        'occasions': options.occasions,
      };
    }
    return {
      'materials': <String>[],
      'sizes': <String>[],
      'weights': <String>[],
      'genders': <String>[],
      'colors': <String>[],
      'occasions': <String>[],
    };
  }
}


