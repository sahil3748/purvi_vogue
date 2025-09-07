import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purvi_vogue/config/cloudinary_config.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/services/cloudinary_service.dart';
import 'package:purvi_vogue/services/firestore_service.dart';

class EnhancedProductFormV2 extends StatefulWidget {
  final ProductModel? product;
  
  const EnhancedProductFormV2({super.key, this.product});

  @override
  State<EnhancedProductFormV2> createState() => _EnhancedProductFormV2State();
}

class _EnhancedProductFormV2State extends State<EnhancedProductFormV2> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _materialController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _colorController = TextEditingController();
  final _careInstructionsController = TextEditingController();
  final _styleTipsController = TextEditingController();
  final _tagsController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  
  final _imagePicker = ImagePicker();
  final _cloudinary = CloudinaryService();
  final _firestoreService = FirestoreService();
  
  List<File> _selectedImages = [];
  List<CategoryModel> _categories = [];
  List<SubcategoryModel> _subcategories = [];
  CategoryModel? _selectedCategory;
  SubcategoryModel? _selectedSubcategory;
  
  bool _isLoading = false;
  bool _isEditing = false;
  bool _inStock = true;
  bool _isFeatured = false;
  
  List<String> _selectedGender = ['Women'];
  List<String> _selectedOccasions = [];

  final List<String> _genderOptions = ['Women', 'Men', 'Unisex'];
  final List<String> _occasionOptions = [
    'Festive', 'Casual', 'Wedding', 'Party', 'Office', 'Traditional', 'Modern'
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.product != null) {
      _isEditing = true;
      _loadProductData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _materialController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _colorController.dispose();
    _careInstructionsController.dispose();
    _styleTipsController.dispose();
    _tagsController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _loadProductData() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _materialController.text = product.material ?? '';
    _weightController.text = product.weight ?? '';
    _dimensionsController.text = product.dimensions ?? '';
    _colorController.text = product.color ?? '';
    _careInstructionsController.text = product.careInstructions ?? '';
    _styleTipsController.text = product.styleTips ?? '';
    _tagsController.text = product.tags.join(', ');
    _inStock = product.inStock;
    _isFeatured = product.isFeatured;
    _selectedGender = List.from(product.gender);
    _selectedOccasions = List.from(product.occasion);
    
    if (product.priceRange != null) {
      _minPriceController.text = product.priceRange!['min']?.toString() ?? '';
      _maxPriceController.text = product.priceRange!['max']?.toString() ?? '';
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesStream = _firestoreService.watchCategories();
      await for (final categories in categoriesStream) {
        setState(() {
          _categories = categories;
          if (_isEditing && widget.product != null) {
            _selectedCategory = categories.firstWhere(
              (cat) => cat.id == widget.product!.categoryId,
              orElse: () => categories.first,
            );
            _loadSubcategories();
          }
        });
        break;
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadSubcategories() async {
    if (_selectedCategory == null) return;
    
    try {
      final subcategoriesStream = _firestoreService.watchSubcategoriesByCategory(_selectedCategory!.id);
      await for (final subcategories in subcategoriesStream) {
        setState(() {
          _subcategories = subcategories;
          if (_isEditing && widget.product != null) {
            _selectedSubcategory = subcategories.firstWhere(
              (sub) => sub.id == widget.product!.subCategoryId,
              orElse: () => subcategories.isNotEmpty ? subcategories.first : null as dynamic,
            );
          }
        });
        break;
      }
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage(
      imageQuality: 85,
    );
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedSubcategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subcategory'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> imageUrls = [];
      
      // Upload new images
      for (final file in _selectedImages) {
        final url = await _cloudinary.uploadImage(
          file: file,
          cloudName: CloudinaryConfig.cloudName,
          uploadPreset: CloudinaryConfig.uploadPreset,
        );
        imageUrls.add(url);
      }

      // Keep existing images if editing
      if (_isEditing && widget.product != null) {
        imageUrls.addAll(widget.product!.imageUrls);
      }

      // Parse price range
      Map<String, num?>? priceRange;
      if (_minPriceController.text.isNotEmpty || _maxPriceController.text.isNotEmpty) {
        priceRange = {
          'min': _minPriceController.text.isNotEmpty 
              ? double.tryParse(_minPriceController.text) 
              : null,
          'max': _maxPriceController.text.isNotEmpty 
              ? double.tryParse(_maxPriceController.text) 
              : null,
        };
      }

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priceRange: priceRange,
        categoryId: _selectedCategory!.id,
        subCategoryId: _selectedSubcategory!.id,
        gender: _selectedGender,
        imageUrls: imageUrls,
        tags: tags,
        material: _materialController.text.trim().isEmpty 
            ? null 
            : _materialController.text.trim(),
        weight: _weightController.text.trim().isEmpty 
            ? null 
            : _weightController.text.trim(),
        dimensions: _dimensionsController.text.trim().isEmpty 
            ? null 
            : _dimensionsController.text.trim(),
        color: _colorController.text.trim().isEmpty 
            ? null 
            : _colorController.text.trim(),
        careInstructions: _careInstructionsController.text.trim().isEmpty 
            ? null 
            : _careInstructionsController.text.trim(),
        inStock: _inStock,
        isFeatured: _isFeatured,
        styleTips: _styleTipsController.text.trim().isEmpty 
            ? null 
            : _styleTipsController.text.trim(),
        occasion: _selectedOccasions,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await _firestoreService.updateProduct(product);
      } else {
        await _firestoreService.addProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing 
                ? 'Product updated successfully!' 
                : 'Product created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Product' : 'Add New Product',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isLoading)
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Product Information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a detailed product listing with comprehensive information',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Basic Information Card
              _buildCard(
                'Basic Information',
                Icons.info,
                [
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('Product Name *', 'Enter product name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: _buildInputDecoration('Description', 'Detailed product description...'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Min Price (₹)', '0'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Max Price (₹)', '0'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Category & Subcategory Card
              _buildCard(
                'Category & Classification',
                Icons.category,
                [
                  DropdownButtonFormField<CategoryModel>(
                    value: _selectedCategory,
                    decoration: _buildInputDecoration('Category *', 'Select category'),
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
                      });
                      if (value != null) {
                        _loadSubcategories();
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SubcategoryModel>(
                    value: _selectedSubcategory,
                    decoration: _buildInputDecoration('Subcategory *', 'Select subcategory'),
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
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a subcategory';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: _buildInputDecoration('Tags', 'Enter tags separated by commas'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Target Audience Card
              _buildCard(
                'Target Audience',
                Icons.people,
                [
                  Text(
                    'Gender',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _genderOptions.map((gender) {
                      return FilterChip(
                        label: Text(gender),
                        selected: _selectedGender.contains(gender),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGender.add(gender);
                            } else {
                              _selectedGender.remove(gender);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Occasions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _occasionOptions.map((occasion) {
                      return FilterChip(
                        label: Text(occasion),
                        selected: _selectedOccasions.contains(occasion),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedOccasions.add(occasion);
                            } else {
                              _selectedOccasions.remove(occasion);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Product Details Card
              _buildCard(
                'Product Details',
                Icons.inventory,
                [
                  TextFormField(
                    controller: _materialController,
                    decoration: _buildInputDecoration('Material', 'e.g., 92.5 Sterling Silver'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: _buildInputDecoration('Weight', 'e.g., 15g'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _dimensionsController,
                          decoration: _buildInputDecoration('Dimensions', 'e.g., 18 inches'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _colorController,
                    decoration: _buildInputDecoration('Color', 'e.g., Rose Gold'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _careInstructionsController,
                    maxLines: 3,
                    decoration: _buildInputDecoration('Care Instructions', 'How to care for this product...'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _styleTipsController,
                    maxLines: 3,
                    decoration: _buildInputDecoration('Style Tips', 'How to style this product...'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Status & Settings Card
              _buildCard(
                'Status & Settings',
                Icons.settings,
                [
                  SwitchListTile(
                    title: const Text('In Stock'),
                    subtitle: const Text('Product is available for purchase'),
                    value: _inStock,
                    onChanged: (value) {
                      setState(() {
                        _inStock = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Featured Product'),
                    subtitle: const Text('Show this product in featured section'),
                    value: _isFeatured,
                    onChanged: (value) {
                      setState(() {
                        _isFeatured = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Images Card
              _buildCard(
                'Product Images',
                Icons.image,
                [
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
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
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.upload),
                      label: const Text('Add Images'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: PurviVogueColors.roseGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PurviVogueColors.roseGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_isEditing ? 'Update Product' : 'Create Product'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: PurviVogueColors.roseGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: PurviVogueColors.roseGold,
          width: 2,
        ),
      ),
    );
  }
}
