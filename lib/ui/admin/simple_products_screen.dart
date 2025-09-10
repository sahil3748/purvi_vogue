import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/luxury_theme.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/services/firestore_service.dart';

class SimpleProductsScreen extends StatefulWidget {
  const SimpleProductsScreen({super.key});

  @override
  State<SimpleProductsScreen> createState() => _SimpleProductsScreenState();
}

class _SimpleProductsScreenState extends State<SimpleProductsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _materialController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  ProductModel? _editingProduct;
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<SubcategoryModel> _subcategories = [];
  List<SubcategoryModel> _filteredSubcategories = [];
  CategoryModel? _selectedCategory;
  SubcategoryModel? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _firestoreService.getProducts();
      final categories = await _firestoreService.getCategories();
      final subcategories = await _firestoreService.getSubcategories();
      setState(() {
        _products = products;
        _categories = categories;
        _subcategories = subcategories;
      });
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

  void _onCategoryChanged(CategoryModel? category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = null;
      _filteredSubcategories = category != null
          ? _subcategories.where((sub) => sub.categoryId == category.id).toList()
          : [];
    });
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
      final minPrice = double.tryParse(_minPriceController.text.trim()) ?? 0.0;
      final maxPrice = double.tryParse(_maxPriceController.text.trim()) ?? minPrice;
      
      if (_isEditing && _editingProduct != null) {
        // Update existing product
        final updatedProduct = ProductModel(
          id: _editingProduct!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          priceRange: {'min': minPrice, 'max': maxPrice},
          categoryId: _selectedCategory!.id,
          subCategoryId: _selectedSubcategory!.id,
          gender: ['Unisex'], // Default gender
          imageUrls: _editingProduct!.imageUrls,
          material: _materialController.text.trim().isEmpty ? null : _materialController.text.trim(),
          createdAt: _editingProduct!.createdAt,
        );
        await _firestoreService.updateProduct(updatedProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
        }
      } else {
        // Create new product
        final newProduct = ProductModel(
          id: '', // Firestore will generate this
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          priceRange: {'min': minPrice, 'max': maxPrice},
          categoryId: _selectedCategory!.id,
          subCategoryId: _selectedSubcategory!.id,
          gender: ['Unisex'], // Default gender
          imageUrls: [],
          material: _materialController.text.trim().isEmpty ? null : _materialController.text.trim(),
          createdAt: DateTime.now(),
        );
        await _firestoreService.addProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
        }
      }
      _resetForm();
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: PurviVogueColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _firestoreService.deleteProduct(product.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _editProduct(ProductModel product) {
    final category = _categories.firstWhere(
      (cat) => cat.id == product.categoryId,
      orElse: () => _categories.first,
    );
    
    setState(() {
      _isEditing = true;
      _editingProduct = product;
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _minPriceController.text = (product.priceRange?['min'] ?? 0).toString();
      _maxPriceController.text = (product.priceRange?['max'] ?? 0).toString();
      _materialController.text = product.material ?? '';
      _selectedCategory = category;
      _filteredSubcategories = _subcategories
          .where((sub) => sub.categoryId == category.id)
          .toList();
      _selectedSubcategory = _filteredSubcategories.firstWhere(
        (sub) => sub.id == product.subCategoryId,
        orElse: () => _filteredSubcategories.first,
      );
    });
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingProduct = null;
      _selectedCategory = null;
      _selectedSubcategory = null;
      _filteredSubcategories = [];
      _nameController.clear();
      _descriptionController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _materialController.clear();
    });
  }

  String _getCategoryName(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getSubcategoryName(String subcategoryId) {
    try {
      return _subcategories.firstWhere((sub) => sub.id == subcategoryId).name;
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getPriceDisplay(ProductModel product) {
    final priceRange = product.priceRange;
    if (priceRange == null) return 'No price';
    final min = priceRange['min'] ?? 0;
    final max = priceRange['max'] ?? min;
    if (min == max) {
      return '₹${min.toStringAsFixed(0)}';
    }
    return '₹${min.toStringAsFixed(0)} - ₹${max.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PurviVogueColors.white,
              PurviVogueColors.softCream,
            ],
          ),
        ),
        child: Column(
          children: [
            // Form Section
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PurviVogueColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: PurviVogueColors.charcoal.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Edit Product' : 'Add New Product',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: PurviVogueColors.deepNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Category and Subcategory Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<CategoryModel>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: _onCategoryChanged,
                            validator: (value) => value == null ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<SubcategoryModel>(
                            value: _selectedSubcategory,
                            decoration: const InputDecoration(
                              labelText: 'Subcategory',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.subdirectory_arrow_right),
                            ),
                            items: _filteredSubcategories.map((subcategory) {
                              return DropdownMenuItem(
                                value: subcategory,
                                child: Text(subcategory.name),
                              );
                            }).toList(),
                            onChanged: (SubcategoryModel? value) {
                              setState(() => _selectedSubcategory = value);
                            },
                            validator: (value) => value == null ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Price Range Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Min Price',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Enter valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _maxPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Max Price (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                if (double.tryParse(value) == null) {
                                  return 'Enter valid price';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _materialController,
                      decoration: const InputDecoration(
                        labelText: 'Material (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PurviVogueColors.deepNavy,
                              foregroundColor: PurviVogueColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        PurviVogueColors.white,
                                      ),
                                    ),
                                  )
                                : Text(_isEditing ? 'Update Product' : 'Add Product'),
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: _resetForm,
                            child: const Text('Cancel'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Products List
            Expanded(
              child: _isLoading && _products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? const Center(
                          child: Text(
                            'No products found. Add your first product above.',
                            style: TextStyle(
                              fontSize: 16,
                              color: PurviVogueColors.charcoal,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: PurviVogueColors.roseGold,
                                  child: Text(
                                    product.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: PurviVogueColors.deepNavy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Material: ${product.material ?? 'Not specified'}'),
                                    Text('Price: ${_getPriceDisplay(product)}'),
                                    Text(
                                      '${_getCategoryName(product.categoryId)} > ${_getSubcategoryName(product.subCategoryId)}',
                                      style: TextStyle(
                                        color: PurviVogueColors.deepNavy,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: PurviVogueColors.deepNavy,
                                      onPressed: () => _editProduct(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: PurviVogueColors.error,
                                      onPressed: () => _deleteProduct(product),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
