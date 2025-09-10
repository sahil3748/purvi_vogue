import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purvi_vogue/config/luxury_theme.dart';
import 'package:purvi_vogue/config/cloudinary_config.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/models/product_type.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/services/cloudinary_service.dart';
import 'package:purvi_vogue/services/firestore_service.dart';

class ProductManagementScreen extends StatefulWidget {
  final ProductModel? editingProduct;

  const ProductManagementScreen({super.key, this.editingProduct});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _longDescriptionController = TextEditingController();
  final _materialController = TextEditingController();
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _careInstructionsController = TextEditingController();
  final _styleTipsController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isUploadingImages = false;

  // Data lists
  List<CategoryModel> _categories = [];
  List<SubcategoryModel> _subcategories = [];
  List<ProductTypeModel> _productTypes = [];

  // Selected values
  CategoryModel? _selectedCategory;
  SubcategoryModel? _selectedSubcategory;
  List<String> _selectedProductTypes = [];
  List<String> _selectedGenders = [];
  List<String> _selectedColors = [];
  List<String> _selectedTags = [];
  List<String> _selectedOccasions = [];

  // Boolean flags
  bool _isAvailable = true;
  bool _inStock = true;
  bool _isBestSeller = false;
  bool _isFeatured = false;

  // Images
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];

  // Dynamic options from category
  List<String> _availableMaterials = [];
  List<String> _availableSizes = [];
  List<String> _availableWeights = [];
  List<String> _availableGenders = [];
  List<String> _availableColors = [];
  List<String> _availableOccasions = [];

  // Step tracking
  int _currentStep = 0;
  final int _totalSteps = 4;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.editingProduct != null) {
      _isEditing = true;
      final product = widget.editingProduct!;

      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _longDescriptionController.text = product.longDescription ?? '';
      _materialController.text = product.material ?? '';
      _weightController.text = product.weight ?? '';
      _sizeController.text = product.size ?? '';
      _dimensionsController.text = product.dimensions ?? '';
      _careInstructionsController.text = product.careInstructions ?? '';
      _styleTipsController.text = product.styleTips ?? '';

      if (product.priceRange != null) {
        _minPriceController.text = product.priceRange!['min']?.toString() ?? '';
        _maxPriceController.text = product.priceRange!['max']?.toString() ?? '';
      }

      _selectedProductTypes = List.from(product.productTypes);
      _selectedGenders = List.from(product.gender);
      _selectedColors = List.from(product.colors);
      _selectedTags = List.from(product.tags);
      _selectedOccasions = List.from(product.occasion);

      _isAvailable = product.isAvailable;
      _inStock = product.inStock;
      _isBestSeller = product.isBestSeller;
      _isFeatured = product.isFeatured;

      _existingImageUrls = List.from(product.imageUrls);
      
      // For editing mode, start at the last step since all data is already filled
      _currentStep = _totalSteps - 1;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _firestoreService.getCategories();
      final productTypes = await _firestoreService.getProductTypes();

      setState(() {
        _categories = categories;
        _productTypes = productTypes;
      });

      if (_isEditing && widget.editingProduct != null) {
        final product = widget.editingProduct!;
        _selectedCategory = _categories.firstWhere(
          (cat) => cat.id == product.categoryId,
          orElse: () => _categories.isNotEmpty
              ? _categories.first
              : CategoryModel(id: '', name: ''),
        );

        if (_selectedCategory != null && _selectedCategory!.id.isNotEmpty) {
          await _loadSubcategories(_selectedCategory!.id);
          await _loadCategoryOptions(_selectedCategory!.id);
          _selectedSubcategory = _subcategories.firstWhere(
            (sub) => sub.id == product.subCategoryId,
            orElse: () => _subcategories.isNotEmpty
                ? _subcategories.first
                : SubcategoryModel(id: '', categoryId: '', name: ''),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategoryOptions(String categoryId) async {
    try {
      final options = await _firestoreService.getAllOptionsForCategory(categoryId);
      setState(() {
        _availableMaterials = options['materials'] ?? [];
        _availableSizes = options['sizes'] ?? [];
        _availableWeights = options['weights'] ?? [];
        _availableGenders = options['genders'] ?? [];
        _availableColors = options['colors'] ?? [];
        _availableOccasions = options['occasions'] ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading category options: $e')),
        );
      }
    }
  }

  Future<void> _loadSubcategories(String categoryId) async {
    try {
      final subcategories = await _firestoreService.getSubcategories();
      setState(() {
        _subcategories = subcategories
            .where((sub) => sub.categoryId == categoryId)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subcategories: $e')),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images.map((xfile) => File(xfile.path)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return _existingImageUrls;

    setState(() => _isUploadingImages = true);
    List<String> imageUrls = List.from(_existingImageUrls);

    try {
      for (File image in _selectedImages) {
        final url = await _cloudinaryService.uploadImage(
          file: image,
          cloudName: CloudinaryConfig.cloudName,
          uploadPreset: CloudinaryConfig.uploadPreset,
        );
        imageUrls.add(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading images: $e')));
      }
    } finally {
      setState(() => _isUploadingImages = false);
    }

    return imageUrls;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedSubcategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and subcategory')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final imageUrls = await _uploadImages();

      Map<String, num?>? priceRange;
      if (_minPriceController.text.isNotEmpty ||
          _maxPriceController.text.isNotEmpty) {
        priceRange = {
          'min': _minPriceController.text.isNotEmpty
              ? num.tryParse(_minPriceController.text)
              : null,
          'max': _maxPriceController.text.isNotEmpty
              ? num.tryParse(_maxPriceController.text)
              : null,
        };
      }

      final product = ProductModel(
        id: _isEditing ? widget.editingProduct!.id : '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        longDescription: _longDescriptionController.text.trim().isEmpty
            ? null
            : _longDescriptionController.text.trim(),
        priceRange: priceRange,
        categoryId: _selectedCategory!.id,
        subCategoryId: _selectedSubcategory!.id,
        productTypes: _selectedProductTypes,
        gender: _selectedGenders,
        imageUrls: imageUrls,
        tags: _selectedTags,
        material: _materialController.text.trim().isEmpty
            ? null
            : _materialController.text.trim(),
        weight: _weightController.text.trim().isEmpty
            ? null
            : _weightController.text.trim(),
        size: _sizeController.text.trim().isEmpty
            ? null
            : _sizeController.text.trim(),
        dimensions: _dimensionsController.text.trim().isEmpty
            ? null
            : _dimensionsController.text.trim(),
        colors: _selectedColors,
        careInstructions: _careInstructionsController.text.trim().isEmpty
            ? null
            : _careInstructionsController.text.trim(),
        isAvailable: _isAvailable,
        inStock: _inStock,
        isBestSeller: _isBestSeller,
        isFeatured: _isFeatured,
        styleTips: _styleTipsController.text.trim().isEmpty
            ? null
            : _styleTipsController.text.trim(),
        occasion: _selectedOccasions,
        createdAt: _isEditing
            ? widget.editingProduct!.createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await _firestoreService.updateProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
        }
      } else {
        await _firestoreService.addProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        backgroundColor: PurviVogueColors.warmGold,
        actions: [
          if (_isLoading || _isUploadingImages)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildCurrentStepContent(),
                    ),
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? PurviVogueColors.warmGold
                          : isCompleted
                              ? Colors.green
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStepTitle(index),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive || isCompleted ? Colors.white : Colors.black54,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (index < _totalSteps - 1)
                  Container(
                    width: 20,
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Category & Type';
      case 1:
        return 'Images';
      case 2:
        return 'Basic Info';
      case 3:
        return 'Details & Save';
      default:
        return 'Step ${step + 1}';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStep();
      case 1:
        return _buildImageStep();
      case 2:
        return _buildBasicInfoStep();
      case 3:
        return _buildDetailsStep();
      default:
        return Container();
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _getNextButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: PurviVogueColors.warmGold,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _getNextButtonText(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextButtonText() {
    if (_currentStep == _totalSteps - 1) {
      return _isEditing ? 'Update Product' : 'Add Product';
    }
    return 'Next';
  }

  VoidCallback? _getNextButtonAction() {
    if (_isLoading || _isUploadingImages) return null;
    
    if (_currentStep == _totalSteps - 1) {
      return _saveProduct;
    }
    
    return _canProceedToNextStep() ? () {
      setState(() {
        _currentStep++;
      });
    } : null;
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedCategory != null && _selectedSubcategory != null;
      case 1:
        return true; // Images are optional
      case 2:
        return _nameController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  Widget _buildCategoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1: Select Category & Product Types',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PurviVogueColors.warmGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the category and subcategory for your product. This will determine available attributes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<CategoryModel>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (CategoryModel? value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSubcategory = null;
                      _subcategories.clear();
                      // Clear category-dependent options
                      _availableMaterials.clear();
                      _availableSizes.clear();
                      _availableWeights.clear();
                      _availableGenders.clear();
                      _availableColors.clear();
                      _availableOccasions.clear();
                    });
                    if (value != null) {
                      _loadSubcategories(value.id);
                      _loadCategoryOptions(value.id);
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SubcategoryModel>(
                  value: _selectedSubcategory,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subdirectory_arrow_right),
                  ),
                  items: _subcategories.map((subcategory) {
                    return DropdownMenuItem(
                      value: subcategory,
                      child: Text(subcategory.name),
                    );
                  }).toList(),
                  onChanged: (SubcategoryModel? value) {
                    setState(() {
                      _selectedSubcategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a subcategory' : null,
                ),
                const SizedBox(height: 24),
                _buildMultiSelectChips(
                  'Product Types',
                  _productTypes.map((pt) => pt.name).toList(),
                  _selectedProductTypes,
                  (selected) => setState(() => _selectedProductTypes = selected),
                ),
              ],
            ),
          ),
        ),
        if (_selectedCategory != null && _selectedSubcategory != null)
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Category Selected Successfully!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${_selectedCategory!.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Subcategory: ${_selectedSubcategory!.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_selectedProductTypes.isNotEmpty)
                    Text(
                      'Product Types: ${_selectedProductTypes.join(", ")}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 2: Add Product Images',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PurviVogueColors.warmGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload high-quality images of your product. You can add multiple images.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(
                      _selectedImages.isEmpty && _existingImageUrls.isEmpty
                          ? 'Add Product Images'
                          : 'Add More Images',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PurviVogueColors.warmGold,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Images:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._existingImageUrls.map(
                              (url) => Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        url,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _existingImageUrls.remove(url);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ..._selectedImages.map(
                              (file) => Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        file,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.remove(file);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No images selected',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Images are optional but recommended',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 3: Basic Product Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PurviVogueColors.warmGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the essential information about your product.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Short Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.article),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 24),
                Text(
                  'Price Range (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Min Price',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Max Price',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 4: Product Details & Attributes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PurviVogueColors.warmGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete the product details and set attributes based on your selected category.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildProductDetailsSection(),
        const SizedBox(height: 16),
        if (_selectedCategory != null) _buildAttributesSection(),
        const SizedBox(height: 16),
        _buildFlagsSection(),
      ],
    );
  }




  Widget _buildProductDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _availableMaterials.isNotEmpty
                      ? DropdownButtonFormField<String>(
                          value: _materialController.text.isEmpty ? null : _materialController.text,
                          decoration: const InputDecoration(
                            labelText: 'Material',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableMaterials.map((material) {
                            return DropdownMenuItem(
                              value: material,
                              child: Text(material),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _materialController.text = value ?? '';
                          },
                        )
                      : TextFormField(
                          controller: _materialController,
                          decoration: const InputDecoration(
                            labelText: 'Material',
                            border: OutlineInputBorder(),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _availableWeights.isNotEmpty
                      ? DropdownButtonFormField<String>(
                          value: _weightController.text.isEmpty ? null : _weightController.text,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableWeights.map((weight) {
                            return DropdownMenuItem(
                              value: weight,
                              child: Text(weight),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _weightController.text = value ?? '';
                          },
                        )
                      : TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            border: OutlineInputBorder(),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _availableSizes.isNotEmpty
                      ? DropdownButtonFormField<String>(
                          value: _sizeController.text.isEmpty ? null : _sizeController.text,
                          decoration: const InputDecoration(
                            labelText: 'Size',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableSizes.map((size) {
                            return DropdownMenuItem(
                              value: size,
                              child: Text(size),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _sizeController.text = value ?? '';
                          },
                        )
                      : TextFormField(
                          controller: _sizeController,
                          decoration: const InputDecoration(
                            labelText: 'Size',
                            border: OutlineInputBorder(),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dimensionsController,
                    decoration: const InputDecoration(
                      labelText: 'Dimensions',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _careInstructionsController,
              decoration: const InputDecoration(
                labelText: 'Care Instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _styleTipsController,
              decoration: const InputDecoration(
                labelText: 'Style Tips',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAttributesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attributes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMultiSelectChips(
              'Gender',
              _availableGenders.isNotEmpty ? _availableGenders : ['Men', 'Women', 'Unisex'],
              _selectedGenders,
              (selected) => setState(() => _selectedGenders = selected),
            ),
            const SizedBox(height: 16),
            _buildMultiSelectChips(
              'Colors',
              _availableColors.isNotEmpty ? _availableColors : ['Black', 'White', 'Gold', 'Silver', 'Rose Gold', 'Blue', 'Red', 'Green', 'Pink', 'Purple', 'Brown', 'Gray'],
              _selectedColors,
              (selected) => setState(() => _selectedColors = selected),
            ),
            const SizedBox(height: 16),
            _buildMultiSelectChips(
              'Occasions',
              _availableOccasions.isNotEmpty ? _availableOccasions : ['Casual', 'Formal', 'Wedding', 'Party', 'Festival', 'Office', 'Travel', 'Sports'],
              _selectedOccasions,
              (selected) => setState(() => _selectedOccasions = selected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Flags',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Available'),
              value: _isAvailable,
              onChanged: (value) => setState(() => _isAvailable = value),
            ),
            SwitchListTile(
              title: const Text('In Stock'),
              value: _inStock,
              onChanged: (value) => setState(() => _inStock = value),
            ),
            SwitchListTile(
              title: const Text('Best Seller'),
              value: _isBestSeller,
              onChanged: (value) => setState(() => _isBestSeller = value),
            ),
            SwitchListTile(
              title: const Text('Featured'),
              value: _isFeatured,
              onChanged: (value) => setState(() => _isFeatured = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips(
    String title,
    List<String> options,
    List<String> selected,
    Function(List<String>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool value) {
                final newSelected = List<String>.from(selected);
                if (value) {
                  newSelected.add(option);
                } else {
                  newSelected.remove(option);
                }
                onChanged(newSelected);
              },
              selectedColor: PurviVogueColors.warmGold.withOpacity(0.3),
              checkmarkColor: PurviVogueColors.warmGold,
            );
          }).toList(),
        ),
      ],
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _longDescriptionController.dispose();
    _materialController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _dimensionsController.dispose();
    _careInstructionsController.dispose();
    _styleTipsController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
}
