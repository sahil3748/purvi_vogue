import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/services/cloudinary_service.dart';

class EnhancedProductForm extends StatefulWidget {
  final ProductModel? product;
  final bool isEditing;

  const EnhancedProductForm({super.key, this.product, this.isEditing = false});

  @override
  State<EnhancedProductForm> createState() => _EnhancedProductFormState();
}

class _EnhancedProductFormState extends State<EnhancedProductForm> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _materialController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _colorController = TextEditingController();
  final _careInstructionsController = TextEditingController();
  final _styleTipsController = TextEditingController();

  // Form data
  String _selectedCategoryId = '';
  String _selectedSubcategoryId = '';
  List<String> _selectedGenders = [];
  List<String> _selectedTags = [];
  List<String> _selectedOccasions = [];
  List<String> _imageUrls = [];
  bool _inStock = true;
  bool _isFeatured = false;

  // Available options
  List<CategoryModel> _categories = [];
  List<SubcategoryModel> _subcategories = [];
  List<String> _availableGenders = ['Women', 'Men', 'Unisex'];
  List<String> _availableOccasions = [
    'Festive',
    'Casual',
    'Wedding',
    'Office',
    'Party',
    'Traditional',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.product != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _materialController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _colorController.dispose();
    _careInstructionsController.dispose();
    _styleTipsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadCategories(), _loadSubcategories()]);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesStream = _firestoreService.watchCategories();
      await for (final categories in categoriesStream) {
        setState(() {
          _categories = categories;
          if (_categories.isNotEmpty && _selectedCategoryId.isEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        });
        break;
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadSubcategories() async {
    try {
      if (_selectedCategoryId.isNotEmpty) {
        final subcategoriesStream = _firestoreService
            .watchSubcategoriesByCategory(_selectedCategoryId);
        await for (final subcategories in subcategoriesStream) {
          setState(() {
            _subcategories = subcategories;
          });
          break;
        }
      }
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  void _populateForm() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _minPriceController.text = product.priceRange?['min']?.toString() ?? '';
    _maxPriceController.text = product.priceRange?['max']?.toString() ?? '';
    _materialController.text = product.material ?? '';
    _weightController.text = product.weight ?? '';
    _dimensionsController.text = product.dimensions ?? '';
    _colorController.text = product.color ?? '';
    _careInstructionsController.text = product.careInstructions ?? '';
    _styleTipsController.text = product.styleTips ?? '';
    _selectedCategoryId = product.categoryId;
    _selectedSubcategoryId = product.subCategoryId;
    _selectedGenders = List.from(product.gender);
    _selectedTags = List.from(product.tags);
    _selectedOccasions = List.from(product.occasion);
    _imageUrls = List.from(product.imageUrls);
    _inStock = product.inStock;
    _isFeatured = product.isFeatured;
  }

  void _onCategoryChanged(String? categoryId) {
    if (categoryId != null && categoryId != _selectedCategoryId) {
      setState(() {
        _selectedCategoryId = categoryId;
        _selectedSubcategoryId = '';
        _subcategories.clear();
      });
      _loadSubcategories();
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priceRange: {
          'min': double.tryParse(_minPriceController.text) ?? 0.0,
          'max': double.tryParse(_maxPriceController.text) ?? 0.0,
        },
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubcategoryId,
        gender: _selectedGenders,
        imageUrls: _imageUrls,
        tags: _selectedTags,
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
      );

      if (widget.isEditing) {
        await _firestoreService.updateProduct(product);
      } else {
        await _firestoreService.addProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Product updated successfully!'
                  : 'Product added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'Add New Product'),
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.roseGold,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: PurviVogueColors.roseGold,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildPricingSection(),
                  const SizedBox(height: 24),
                  _buildCategorySection(),
                  const SizedBox(height: 24),
                  _buildDetailsSection(),
                  const SizedBox(height: 24),
                  _buildImagesSection(),
                  const SizedBox(height: 24),
                  _buildSettingsSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Product Name *',
            hintText: 'Enter product name',
          ),
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
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Enter product description',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _buildSection(
      title: 'Pricing',
      icon: Icons.attach_money,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minPriceController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Price *',
                  hintText: '0.00',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Minimum price is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxPriceController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Price',
                  hintText: '0.00',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    final minPrice =
                        double.tryParse(_minPriceController.text) ?? 0;
                    final maxPrice = double.tryParse(value) ?? 0;
                    if (maxPrice < minPrice) {
                      return 'Max price must be >= min price';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return _buildSection(
      title: 'Category & Classification',
      icon: Icons.category,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'Category *',
            hintText: 'Select a category',
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: _onCategoryChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        if (_subcategories.isNotEmpty)
          DropdownButtonFormField<String>(
            value: _selectedSubcategoryId.isEmpty
                ? null
                : _selectedSubcategoryId,
            decoration: const InputDecoration(
              labelText: 'Subcategory',
              hintText: 'Select a subcategory (optional)',
            ),
            items: _subcategories.map((subcategory) {
              return DropdownMenuItem(
                value: subcategory.id,
                child: Text(subcategory.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubcategoryId = value ?? '';
              });
            },
          ),
        const SizedBox(height: 16),
        const Text(
          'Target Gender *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableGenders.map((gender) {
            return FilterChip(
              label: Text(gender),
              selected: _selectedGenders.contains(gender),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGenders.add(gender);
                  } else {
                    _selectedGenders.remove(gender);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (_selectedGenders.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one gender',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return _buildSection(
      title: 'Product Details',
      icon: Icons.details,
      children: [
        TextFormField(
          controller: _materialController,
          decoration: const InputDecoration(
            labelText: 'Material',
            hintText: 'e.g., 18K Gold, Pure Silk',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  hintText: 'e.g., 10g',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _dimensionsController,
                decoration: const InputDecoration(
                  labelText: 'Dimensions',
                  hintText: 'e.g., 10x5cm',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _colorController,
          decoration: const InputDecoration(
            labelText: 'Color',
            hintText: 'e.g., Rose Gold, Navy Blue',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _careInstructionsController,
          decoration: const InputDecoration(
            labelText: 'Care Instructions',
            hintText: 'How to care for this product',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _styleTipsController,
          decoration: const InputDecoration(
            labelText: 'Style Tips',
            hintText: 'How to style this product',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const Text(
          'Occasions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableOccasions.map((occasion) {
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
    );
  }

  Widget _buildImagesSection() {
    return _buildSection(
      title: 'Product Images',
      icon: Icons.image,
      children: [
        // TODO: Implement image upload functionality
        const Text('Image upload functionality will be implemented here'),
        const SizedBox(height: 16),
        if (_imageUrls.isNotEmpty)
          Wrap(
            spacing: 8,
            children: _imageUrls.map((url) {
              return Chip(
                label: Text(url.split('/').last),
                onDeleted: () {
                  setState(() {
                    _imageUrls.remove(url);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return _buildSection(
      title: 'Product Settings',
      icon: Icons.settings,
      children: [
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
          subtitle: const Text('Show in featured products section'),
          value: _isFeatured,
          onChanged: (value) {
            setState(() {
              _isFeatured = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: PurviVogueColors.roseGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(widget.isEditing ? 'Update Product' : 'Add Product'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: PurviVogueColors.roseGold,
              side: const BorderSide(color: PurviVogueColors.roseGold),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: PurviVogueColors.roseGold, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PurviVogueColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
