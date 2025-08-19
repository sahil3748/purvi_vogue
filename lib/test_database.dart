import 'package:purvi_vogue/services/database_migration_service.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/banner.dart';
import 'package:purvi_vogue/config/database_constants.dart';

/// Test class to demonstrate the new database structure
class DatabaseTest {
  final FirestoreService _firestoreService = FirestoreService();
  final DatabaseMigrationService _migrationService = DatabaseMigrationService();

  /// Test the complete database workflow
  Future<void> testDatabaseWorkflow() async {
    try {
      print('🚀 Starting database test...\n');

      // 1. Initialize database with sample data
      print('📊 Initializing database with sample data...');
      await _migrationService.initializeDatabase();
      print('✅ Database initialized successfully!\n');

      // 2. Test watching categories
      print('👀 Testing category watching...');
      final categoriesStream = _firestoreService.watchCategories();
      categoriesStream.listen((categories) {
        print('📁 Found ${categories.length} categories:');
        for (final category in categories) {
          print('   - ${category.name}: ${category.description}');
        }
      });
      print('✅ Category watching test completed!\n');

      // 3. Test watching subcategories
      print('👀 Testing subcategory watching...');
      final subcategoriesStream = _firestoreService.watchSubcategories();
      subcategoriesStream.listen((subcategories) {
        print('📂 Found ${subcategories.length} subcategories:');
        for (final subcategory in subcategories) {
          print('   - ${subcategory.name} (Category: ${subcategory.categoryId})');
        }
      });
      print('✅ Subcategory watching test completed!\n');

      // 4. Test watching products
      print('👀 Testing product watching...');
      final productsStream = _firestoreService.watchProducts();
      productsStream.listen((products) {
        print('🛍️ Found ${products.length} products:');
        for (final product in products) {
          print('   - ${product.name} (₹${product.priceRange?['min']}-${product.priceRange?['max']})');
          print('     Gender: ${product.gender.join(', ')}');
          print('     Material: ${product.material ?? 'N/A'}');
          print('     In Stock: ${product.inStock}');
        }
      });
      print('✅ Product watching test completed!\n');

      // 5. Test watching banners
      print('👀 Testing banner watching...');
      final bannersStream = _firestoreService.watchBanners();
      bannersStream.listen((banners) {
        print('🎨 Found ${banners.length} banners:');
        for (final banner in banners) {
          print('   - ${banner.title}: ${banner.ctaText}');
        }
      });
      print('✅ Banner watching test completed!\n');

      // 6. Test filtering products by gender
      print('🔍 Testing gender filtering...');
      final womenProductsStream = _firestoreService.watchProductsByGender('Women');
      womenProductsStream.listen((products) {
        print('👩 Found ${products.length} women\'s products');
      });
      print('✅ Gender filtering test completed!\n');

      // 7. Test featured products
      print('⭐ Testing featured products...');
      final featuredProductsStream = _firestoreService.watchFeaturedProducts();
      featuredProductsStream.listen((products) {
        print('🌟 Found ${products.length} featured products');
      });
      print('✅ Featured products test completed!\n');

      // 8. Test in-stock products
      print('📦 Testing in-stock products...');
      final inStockProductsStream = _firestoreService.watchInStockProducts();
      inStockProductsStream.listen((products) {
        print('✅ Found ${products.length} in-stock products');
      });
      print('✅ In-stock products test completed!\n');

      print('🎉 All database tests completed successfully!');
      print('📱 Your new database structure is working perfectly!');

    } catch (e) {
      print('❌ Error during database test: $e');
    }
  }

  /// Test adding a new category
  Future<void> testAddCategory() async {
    try {
      print('➕ Testing category addition...');
      
      final categoryId = await _firestoreService.addCategory(
        name: 'Test Category',
        description: 'This is a test category',
        thumbnailUrl: 'https://example.com/test-thumb.jpg',
      );
      
      print('✅ Category added with ID: $categoryId');
    } catch (e) {
      print('❌ Error adding category: $e');
    }
  }

  /// Test adding a new product
  Future<void> testAddProduct() async {
    try {
      print('➕ Testing product addition...');
      
      // Get first category and subcategory for testing
      final categories = await _firestoreService.watchCategories().first;
      final subcategories = await _firestoreService.watchSubcategories().first;
      
      if (categories.isNotEmpty && subcategories.isNotEmpty) {
        final product = ProductModel(
          id: '',
          name: 'Test Product',
          description: 'This is a test product',
          priceRange: {'min': 500, 'max': 800},
          categoryId: categories.first.id,
          subCategoryId: subcategories.first.id,
          gender: ['Women'],
          imageUrls: ['https://example.com/test1.jpg'],
          tags: ['test', 'sample'],
          material: 'Test Material',
          weight: '50g',
          dimensions: 'Length: 20cm',
          color: 'Test Color',
          careInstructions: 'Test care instructions',
          inStock: true,
          isFeatured: false,
          styleTips: 'Test style tips',
          occasion: ['Casual'],
        );
        
        final productId = await _firestoreService.addProduct(product);
        print('✅ Product added with ID: $productId');
      } else {
        print('⚠️ No categories or subcategories found for testing');
      }
    } catch (e) {
      print('❌ Error adding product: $e');
    }
  }

  /// Clean up test data
  Future<void> cleanupTestData() async {
    try {
      print('🧹 Cleaning up test data...');
      await _migrationService.cleanupDatabase();
      print('✅ Test data cleaned up successfully!');
    } catch (e) {
      print('❌ Error cleaning up test data: $e');
    }
  }
}

/// Main function to run tests (uncomment to test)
/*
void main() async {
  final test = DatabaseTest();
  
  // Run the complete workflow test
  await test.testDatabaseWorkflow();
  
  // Wait a bit to see the streams in action
  await Future.delayed(Duration(seconds: 5));
  
  // Test adding new items
  await test.testAddCategory();
  await test.testAddProduct();
  
  // Wait to see the new items
  await Future.delayed(Duration(seconds: 3));
  
  // Clean up (uncomment if you want to remove test data)
  // await test.cleanupTestData();
}
*/
