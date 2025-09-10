import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purvi_vogue/config/cloudinary_config.dart';
import 'package:purvi_vogue/config/luxury_theme.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/services/cloudinary_service.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/ui/admin/subcategories_list_screen.dart';

class SimpleSubcategoriesScreen extends StatefulWidget {
  const SimpleSubcategoriesScreen({super.key});

  @override
  State<SimpleSubcategoriesScreen> createState() =>
      _SimpleSubcategoriesScreenState();
}

class _SimpleSubcategoriesScreenState extends State<SimpleSubcategoriesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isUploadingImage = false;
  SubcategoryModel? _editingSubcategory;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _firestoreService.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSubcategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Upload image first if a new image is selected
      String? finalImageUrl = await _uploadImage();

      if (_isEditing && _editingSubcategory != null) {
        // Update existing subcategory
        final updatedSubcategory = SubcategoryModel(
          id: _editingSubcategory!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _selectedCategory!.id,
          thumbnailUrl: finalImageUrl,
        );
        await _firestoreService.updateSubcategory(updatedSubcategory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subcategory updated successfully!')),
          );
        }
      } else {
        // Create new subcategory
        final newSubcategory = SubcategoryModel(
          id: '', // Firestore will generate this
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _selectedCategory!.id,
          thumbnailUrl: finalImageUrl,
        );
        await _firestoreService.addSubcategory(newSubcategory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subcategory added successfully!')),
          );
        }
      }
      _resetForm();
      // Navigate back after successful save
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving subcategory: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _uploadedImageUrl =
              null; // Clear any existing URL when new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _uploadedImageUrl;

    setState(() => _isUploadingImage = true);
    try {
      final imageUrl = await _cloudinaryService.uploadImage(
        file: _selectedImage!,
        cloudName: CloudinaryConfig.cloudName,
        uploadPreset: CloudinaryConfig.uploadPreset,
      );

      setState(() {
        _uploadedImageUrl = imageUrl;
        _selectedImage = null; // Clear selected image after successful upload
      });

      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingSubcategory = null;
      _nameController.clear();
      _descriptionController.clear();
      _selectedCategory = null;
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subcategory'),
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.white,
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => const SubcategoriesListScreen(),
          //       ),
          //     );
          //   },
          //   icon: const Icon(Icons.list),
          //   tooltip: 'View All Subcategories',
          // ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [PurviVogueColors.white, PurviVogueColors.softCream],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
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
                    _isEditing ? 'Edit Subcategory' : 'Add New Subcategory',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: PurviVogueColors.deepNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<CategoryModel>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
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
                      setState(() => _selectedCategory = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Subcategory Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.subdirectory_arrow_right),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a subcategory name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Image Upload Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.image,
                              color: PurviVogueColors.deepNavy,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Subcategory Image (Optional)',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: PurviVogueColors.deepNavy,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Image Preview
                        if (_selectedImage != null ||
                            _uploadedImageUrl != null) ...[
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : _uploadedImageUrl != null
                                  ? Image.network(
                                      _uploadedImageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.error,
                                                color: Colors.red,
                                              ),
                                            );
                                          },
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Image Action Buttons
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading || _isUploadingImage
                                  ? null
                                  : _pickImage,
                              icon: const Icon(Icons.photo_library, size: 18),
                              label: Text(
                                _selectedImage != null ||
                                        _uploadedImageUrl != null
                                    ? 'Change Image'
                                    : 'Select Image',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PurviVogueColors.roseGold,
                                foregroundColor: PurviVogueColors.deepNavy,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            if (_selectedImage != null ||
                                _uploadedImageUrl != null) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: _isLoading || _isUploadingImage
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedImage = null;
                                          _uploadedImageUrl = null;
                                        });
                                      },
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Remove'),
                                style: TextButton.styleFrom(
                                  foregroundColor: PurviVogueColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (_isUploadingImage) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Uploading image...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveSubcategory,
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
                              : Text(
                                  _isEditing
                                      ? 'Update Subcategory'
                                      : 'Add Subcategory',
                                ),
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
        ),
      ),
    );
  }
}
