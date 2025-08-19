# 🗄️ Purvi Vogue Database Structure

This document outlines the complete Firestore database structure for the Purvi Vogue Flutter application.

## 📊 Database Collections Overview

### 1. **Categories Collection** (`/categories`)
- **Purpose**: Main product categories (e.g., Jewelry, Clothing, Accessories)
- **Fields**:
  - `id` (auto-generated or custom, e.g., `cat01`)
  - `name` (e.g., "Jewelry")
  - `description` (optional)
  - `thumbnailUrl` (category image)
  - `createdAt` (timestamp)

### 2. **Subcategories Collection** (`/subcategories`)
- **Purpose**: Subdivisions within categories (e.g., Necklaces under Jewelry)
- **Fields**:
  - `id` (auto-generated or custom, e.g., `subcat01`)
  - `categoryId` (reference to `/categories/cat01`)
  - `name` (e.g., "Necklaces")
  - `description` (optional)
  - `thumbnailUrl` (optional)

### 3. **Products Collection** (`/products`)
- **Purpose**: Individual product items with detailed information
- **Fields**:
  - `id` (auto-generated, e.g., `prod001`)
  - `name` (product name)
  - `description` (detailed description)
  - `priceRange` {min, max} (price range object)
  - `categoryId` (reference to categories)
  - `subCategoryId` (reference to subcategories)
  - `gender` ["Women", "Men", "Unisex"]
  - `imageUrls` [array of image URLs]
  - `tags` [array of tags]
  - `material` (e.g., "92.5 Sterling Silver")
  - `weight` (optional)
  - `dimensions` (optional)
  - `color`
  - `careInstructions`
  - `inStock` (true/false)
  - `isFeatured` (true/false)
  - `styleTips` (optional)
  - `occasion` [array of occasions]
  - `createdAt` (timestamp)

### 4. **Banners Collection** (`/banners`)
- **Purpose**: Homepage promotional banners
- **Fields**:
  - `id`
  - `title`
  - `imageUrl`
  - `ctaText` (call-to-action text)
  - `linkCategoryId` (reference to category)

### 5. **Admins Collection** (`/admins`)
- **Purpose**: Admin user management
- **Fields**:
  - `uid` (user ID)
  - `email`
  - `role` (super_admin, admin, moderator)

## 🔄 Data Flow

```
Categories → Subcategories → Products
    ↓              ↓           ↓
  Banners ←→ Products ←→ Gender Filtering
```

## 📱 Flutter Implementation

### Models
- `CategoryModel` - Category data structure
- `SubcategoryModel` - Subcategory data structure  
- `ProductModel` - Product data structure
- `BannerModel` - Banner data structure
- `AdminModel` - Admin data structure

### Services
- `FirestoreService` - Main database operations
- `DatabaseMigrationService` - Database setup and migration

### Constants
- `DatabaseConstants` - Collection names, field names, and validation rules

## 🚀 Getting Started

### 1. Initialize Database
```dart
final migrationService = DatabaseMigrationService();
await migrationService.initializeDatabase();
```

### 2. Watch Categories
```dart
final categoriesStream = FirestoreService().watchCategories();
```

### 3. Watch Products by Category
```dart
final productsStream = FirestoreService().watchProductsByCategory('cat01');
```

### 4. Filter Products by Gender
```dart
final womenProductsStream = FirestoreService().watchProductsByGender('Women');
```

## 🔍 Advanced Queries

### Search Products
```dart
final searchResults = FirestoreService().searchProducts('necklace');
```

### Filter by Tags
```dart
final taggedProducts = FirestoreService().filterProductsByTags(['silver', 'ethnic']);
```

### Filter by Occasion
```dart
final weddingProducts = FirestoreService().filterProductsByOccasion(['Wedding']);
```

## 🛡️ Security Rules

The Firestore security rules ensure:
- **Public Read Access**: Products, categories, subcategories, and banners
- **Admin Write Access**: Only authenticated admins can modify data
- **Protected Collections**: Admins collection is restricted to admin users only

## 📋 Sample Data Structure

### Category Example
```json
{
  "name": "Jewelry",
  "description": "All types of jewelry items",
  "thumbnailUrl": "https://example.com/jewelry-thumb.jpg",
  "createdAt": "2025-08-19T10:00:00Z"
}
```

### Product Example
```json
{
  "name": "Silver Oxidized Necklace",
  "description": "Elegant handcrafted necklace",
  "priceRange": { "min": 1200, "max": 1500 },
  "categoryId": "cat01",
  "subCategoryId": "subcat01",
  "gender": ["Women"],
  "imageUrls": ["https://...", "https://..."],
  "tags": ["silver", "ethnic"],
  "material": "92.5 Sterling Silver",
  "weight": "35g",
  "dimensions": "Length: 18cm",
  "color": "Silver",
  "careInstructions": "Keep away from water and perfume",
  "inStock": true,
  "isFeatured": true,
  "styleTips": "Pairs well with ethnic wear",
  "occasion": ["Wedding", "Festive"],
  "createdAt": "2025-08-19T10:00:00Z"
}
```

## 🔧 Migration from Old Structure

If you have existing data with the old structure:

```dart
final migrationService = DatabaseMigrationService();
await migrationService.migrateExistingProducts();
```

This will:
- Convert `subCategory` field to `subCategoryId`
- Add missing required fields with default values
- Maintain data integrity during transition

## 📊 Database Indexes

Ensure you have the following composite indexes in Firestore:

1. **Products Collection**:
   - `categoryId` + `createdAt` (descending)
   - `subCategoryId` + `createdAt` (descending)
   - `gender` + `createdAt` (descending)
   - `isFeatured` + `createdAt` (descending)
   - `inStock` + `createdAt` (descending)

2. **Subcategories Collection**:
   - `categoryId` (for filtering subcategories by category)

## 🎯 Best Practices

1. **Use Constants**: Always use `DatabaseConstants` for field names
2. **Validate Data**: Implement validation before saving to Firestore
3. **Handle Errors**: Implement proper error handling for all database operations
4. **Optimize Queries**: Use appropriate indexes and limit query results
5. **Batch Operations**: Use batch writes for multiple document operations

## 🚨 Important Notes

- **Required Fields**: `name`, `categoryId`, `subCategoryId`, and `gender` are required for products
- **Image URLs**: Store full URLs, not relative paths
- **Price Range**: Always use the `{min, max}` structure
- **Arrays**: Use arrays for `gender`, `tags`, `imageUrls`, and `occasion` fields
- **Timestamps**: Use Firestore timestamps for `createdAt` field

## 📞 Support

For database-related issues or questions, refer to:
- Firestore documentation
- Flutter Firebase documentation
- Project-specific implementation in `lib/services/` and `lib/models/`
