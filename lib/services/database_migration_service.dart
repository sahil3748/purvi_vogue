import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/banner.dart';
import 'package:purvi_vogue/models/admin.dart';
import 'package:purvi_vogue/config/database_constants.dart';

class DatabaseMigrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Initialize the database with sample data for testing
  Future<void> initializeDatabase() async {
    try {
      // Create sample categories
      await _createSampleCategories();
      
      // Create sample subcategories
      await _createSampleSubcategories();
      
      // Create sample products
      await _createSampleProducts();
      
      // Create sample banners
      await _createSampleBanners();
      
      print('Database initialized successfully!');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  /// Create sample categories
  Future<void> _createSampleCategories() async {
    final categories = [
      {
        'name': 'Jewelry',
        'description': 'All types of jewelry items',
        'thumbnailUrl': 'https://example.com/jewelry-thumb.jpg',
      },
      {
        'name': 'Clothing',
        'description': 'Traditional and modern clothing',
        'thumbnailUrl': 'https://example.com/clothing-thumb.jpg',
      },
      {
        'name': 'Accessories',
        'description': 'Fashion accessories and add-ons',
        'thumbnailUrl': 'https://example.com/accessories-thumb.jpg',
      },
    ];

    for (final categoryData in categories) {
      await _firestoreService.addCategory(
        name: categoryData['name']!,
        description: categoryData['description'],
        thumbnailUrl: categoryData['thumbnailUrl'],
      );
    }
  }

  /// Create sample subcategories
  Future<void> _createSampleSubcategories() async {
    // Get category IDs first
    final categoriesSnapshot = await _db.collection(DatabaseConstants.categoriesCollection).get();
    final jewelryCategory = categoriesSnapshot.docs.firstWhere((doc) => doc.data()[DatabaseConstants.nameField] == 'Jewelry');
    final clothingCategory = categoriesSnapshot.docs.firstWhere((doc) => doc.data()[DatabaseConstants.nameField] == 'Clothing');
    final accessoriesCategory = categoriesSnapshot.docs.firstWhere((doc) => doc.data()[DatabaseConstants.nameField] == 'Accessories');

    final subcategories = [
      {
        'categoryId': jewelryCategory.id,
        'name': 'Necklaces',
        'description': 'Chokers, daily wear, statement pieces',
        'thumbnailUrl': 'https://example.com/necklaces-thumb.jpg',
      },
      {
        'categoryId': jewelryCategory.id,
        'name': 'Earrings',
        'description': 'Studs, jhumkas, chandbalis',
        'thumbnailUrl': 'https://example.com/earrings-thumb.jpg',
      },
      {
        'categoryId': clothingCategory.id,
        'name': 'Sarees',
        'description': 'Traditional and designer sarees',
        'thumbnailUrl': 'https://example.com/sarees-thumb.jpg',
      },
      {
        'categoryId': accessoriesCategory.id,
        'name': 'Handbags',
        'description': 'Clutches, totes, shoulder bags',
        'thumbnailUrl': 'https://example.com/handbags-thumb.jpg',
      },
    ];

    for (final subcategoryData in subcategories) {
      final subcategory = SubcategoryModel(
        id: '', // Will be auto-generated
        categoryId: subcategoryData['categoryId']!,
        name: subcategoryData['name']!,
        description: subcategoryData['description'],
        thumbnailUrl: subcategoryData['thumbnailUrl'],
      );
      await _firestoreService.addSubcategory(subcategory);
    }
  }

  /// Create sample products
  Future<void> _createSampleProducts() async {
    // Get category and subcategory IDs
    final categoriesSnapshot = await _db.collection(DatabaseConstants.categoriesCollection).get();
    final subcategoriesSnapshot = await _db.collection(DatabaseConstants.subcategoriesCollection).get();
    
    final jewelryCategory = categoriesSnapshot.docs.firstWhere((doc) => doc.data()[DatabaseConstants.nameField] == 'Jewelry');
    final necklacesSubcategory = subcategoriesSnapshot.docs.firstWhere((doc) => doc.data()[DatabaseConstants.nameField] == 'Necklaces');

    final products = [
      {
        'name': 'Silver Oxidized Necklace',
        'description': 'Elegant handcrafted necklace with traditional design',
        'priceRange': {'min': 1200, 'max': 1500},
        'categoryId': jewelryCategory.id,
        'subCategoryId': necklacesSubcategory.id,
        'gender': ['Women'],
        'imageUrls': ['https://example.com/necklace1.jpg', 'https://example.com/necklace2.jpg'],
        'tags': ['silver', 'ethnic', 'traditional'],
        'material': '92.5 Sterling Silver',
        'weight': '35g',
        'dimensions': 'Length: 18cm',
        'color': 'Silver',
        'careInstructions': 'Keep away from water and perfume',
        'inStock': true,
        'isFeatured': true,
        'styleTips': 'Pairs well with ethnic wear',
        'occasion': ['Wedding', 'Festive'],
      },
      {
        'name': 'Gold Plated Choker',
        'description': 'Modern choker design for contemporary looks',
        'priceRange': {'min': 800, 'max': 1000},
        'categoryId': jewelryCategory.id,
        'subCategoryId': necklacesSubcategory.id,
        'gender': ['Women'],
        'imageUrls': ['https://example.com/choker1.jpg'],
        'tags': ['gold', 'modern', 'choker'],
        'material': 'Gold Plated Brass',
        'weight': '25g',
        'dimensions': 'Length: 16cm',
        'color': 'Gold',
        'careInstructions': 'Store in dry place, avoid chemicals',
        'inStock': true,
        'isFeatured': false,
        'styleTips': 'Perfect for western wear',
        'occasion': ['Casual', 'Party'],
      },
    ];

    for (final productData in products) {
      final product = ProductModel(
        id: '', // Will be auto-generated
        name: productData['name']! as String,
        description: productData['description'] as String?,
        priceRange: Map<String, num?>.from(productData['priceRange'] as Map<String, dynamic>),
        categoryId: productData['categoryId']! as String,
        subCategoryId: productData['subCategoryId']! as String,
        gender: List<String>.from(productData['gender'] as List<dynamic>),
        imageUrls: List<String>.from(productData['imageUrls'] as List<dynamic>),
        tags: List<String>.from(productData['tags'] as List<dynamic>),
        material: productData['material'] as String?,
        weight: productData['weight'] as String?,
        dimensions: productData['dimensions'] as String?,
        color: productData['color'] as String?,
        careInstructions: productData['careInstructions'] as String?,
        inStock: productData['inStock'] as bool,
        isFeatured: productData['isFeatured'] as bool,
        styleTips: productData['styleTips'] as String?,
        occasion: List<String>.from(productData['occasion'] as List<dynamic>),
      );
      await _firestoreService.addProduct(product);
    }
  }

  /// Create sample banners
  Future<void> _createSampleBanners() async {
    // Get category ID for jewelry
    final categoriesSnapshot = await _db.collection(DatabaseConstants.categoriesCollection).get();
    final jewelryCategory = categoriesSnapshot.docs.firstWhere((doc) => doc.data()[DatabaseConstants.nameField] == 'Jewelry');

    final banners = [
      {
        'title': 'Festive Collection',
        'imageUrl': 'https://example.com/festive-banner.jpg',
        'ctaText': 'Shop Now',
        'linkCategoryId': jewelryCategory.id,
      },
      {
        'title': 'New Arrivals',
        'imageUrl': 'https://example.com/new-arrivals-banner.jpg',
        'ctaText': 'Explore',
        'linkCategoryId': jewelryCategory.id,
      },
    ];

    for (final bannerData in banners) {
      final banner = BannerModel(
        id: '', // Will be auto-generated
        title: bannerData['title']!,
        imageUrl: bannerData['imageUrl']!,
        ctaText: bannerData['ctaText']!,
        linkCategoryId: bannerData['linkCategoryId']!,
      );
      await _firestoreService.addBanner(banner);
    }
  }

  /// Migrate existing products to new structure
  Future<void> migrateExistingProducts() async {
    try {
      final productsSnapshot = await _db.collection(DatabaseConstants.productsCollection).get();
      
      for (final doc in productsSnapshot.docs) {
        final data = doc.data();
        
        // Check if product needs migration (has old structure)
        if (data.containsKey('subCategory') && !data.containsKey(DatabaseConstants.subCategoryIdField)) {
          // Migrate old subCategory field to subCategoryId
          await _db.collection(DatabaseConstants.productsCollection).doc(doc.id).update({
            DatabaseConstants.subCategoryIdField: data['subCategory'],
            DatabaseConstants.genderField: ['Women'], // Default gender
            DatabaseConstants.materialField: null,
            DatabaseConstants.weightField: null,
            DatabaseConstants.dimensionsField: null,
            DatabaseConstants.colorField: null,
            DatabaseConstants.careInstructionsField: null,
            DatabaseConstants.inStockField: true, // Default to in stock
            DatabaseConstants.styleTipsField: null,
            DatabaseConstants.occasionField: [], // Default empty occasions
          });
          
          // Remove old field
          await _db.collection(DatabaseConstants.productsCollection).doc(doc.id).update({
            'subCategory': FieldValue.delete(),
          });
        }
      }
      
      print('Product migration completed successfully!');
    } catch (e) {
      print('Error migrating products: $e');
    }
  }

  /// Clean up database (for testing purposes)
  Future<void> cleanupDatabase() async {
    try {
      // Delete all collections
      await _deleteCollection(DatabaseConstants.productsCollection);
      await _deleteCollection(DatabaseConstants.subcategoriesCollection);
      await _deleteCollection(DatabaseConstants.categoriesCollection);
      await _deleteCollection(DatabaseConstants.bannersCollection);
      
      print('Database cleaned up successfully!');
    } catch (e) {
      print('Error cleaning up database: $e');
    }
  }

  /// Helper method to delete a collection
  Future<void> _deleteCollection(String collectionPath) async {
    final collectionRef = _db.collection(collectionPath);
    final query = collectionRef.orderBy(FieldPath.documentId).limit(500);
    
    final querySnapshot = await query.get();
    final batch = _db.batch();
    
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    
    // If we deleted a full batch, there might be more
    if (querySnapshot.docs.length == 500) {
      await _deleteCollection(collectionPath);
    }
  }
}
