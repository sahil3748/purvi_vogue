class DatabaseConstants {
  // Collection Names
  static const String categoriesCollection = 'categories';
  static const String subcategoriesCollection = 'subcategories';
  static const String productsCollection = 'products';
  static const String bannersCollection = 'banners';
  static const String adminsCollection = 'admins';
  static const String usersCollection = 'users';

  // Field Names
  static const String idField = 'id';
  static const String nameField = 'name';
  static const String descriptionField = 'description';
  static const String thumbnailUrlField = 'thumbnailUrl';
  static const String createdAtField = 'createdAt';
  static const String categoryIdField = 'categoryId';
  static const String subCategoryIdField = 'subCategoryId';
  static const String priceRangeField = 'priceRange';
  static const String genderField = 'gender';
  static const String imageUrlsField = 'imageUrls';
  static const String tagsField = 'tags';
  static const String materialField = 'material';
  static const String weightField = 'weight';
  static const String dimensionsField = 'dimensions';
  static const String colorField = 'color';
  static const String careInstructionsField = 'careInstructions';
  static const String inStockField = 'inStock';
  static const String isFeaturedField = 'isFeatured';
  static const String styleTipsField = 'styleTips';
  static const String occasionField = 'occasion';
  static const String titleField = 'title';
  static const String imageUrlField = 'imageUrl';
  static const String ctaTextField = 'ctaText';
  static const String linkCategoryIdField = 'linkCategoryId';
  static const String uidField = 'uid';
  static const String emailField = 'email';
  static const String roleField = 'role';

  // Gender Options
  static const List<String> genderOptions = ['Women', 'Men', 'Unisex'];

  // Role Options
  static const List<String> roleOptions = ['super_admin', 'admin', 'moderator'];

  // Common Occasions
  static const List<String> commonOccasions = [
    'Wedding',
    'Festive',
    'Casual',
    'Party',
    'Office',
    'Traditional',
    'Modern',
    'Daily Wear',
    'Special Occasion',
  ];

  // Common Materials
  static const List<String> commonMaterials = [
    '92.5 Sterling Silver',
    'Gold Plated Brass',
    'Gold Plated Silver',
    'Diamond',
    'Pearl',
    'Gemstone',
    'Plastic',
    'Fabric',
    'Leather',
    'Cotton',
    'Silk',
    'Polyester',
  ];

  // Common Colors
  static const List<String> commonColors = [
    'Silver',
    'Gold',
    'Rose Gold',
    'Black',
    'White',
    'Red',
    'Blue',
    'Green',
    'Pink',
    'Purple',
    'Orange',
    'Yellow',
    'Brown',
    'Grey',
    'Multi-color',
  ];

  // Price Range Constants
  static const int minPrice = 100;
  static const int maxPrice = 100000;
  static const int priceStep = 100;

  // Image Constants
  static const int maxImageCount = 10;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImageSizeMB = 5;

  // Validation Constants
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxTagsCount = 10;
  static const int maxOccasionsCount = 5;
}
