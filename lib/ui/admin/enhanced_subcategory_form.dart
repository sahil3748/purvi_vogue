import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/services/firestore_service.dart';

class EnhancedSubcategoryForm extends StatefulWidget {
  final SubcategoryModel? subcategory;
  final bool isEditing;

  const EnhancedSubcategoryForm({
    super.key,
    this.subcategory,
    this.isEditing = false,
  });

  @override
  State<EnhancedSubcategoryForm> createState() => _EnhancedSubcategoryFormState();
}

class _EnhancedSubcategoryFormState extends State<EnhancedSubcategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();

  // Form data
  String _selectedCategoryId = '';
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.subcategory != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateForm() {
    final subcategory = widget.subcategory!;
    _nameController.text = subcategory.name;
    _descriptionController.text = subcategory.description ?? '';
    _thumbnailUrlController.text = subcategory.thumbnailUrl ?? '';
    _selectedCategoryId = subcategory.categoryId;
  }

  Future<void> _saveSubcategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final subcategory = SubcategoryModel(
        id: widget.subcategory?.id ?? '',
        categoryId: _selectedCategoryId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        thumbnailUrl: _thumbnailUrlController.text.trim().isEmpty ? null : _thumbnailUrlController.text.trim(),
      );

      if (widget.isEditing) {
        await _firestoreService.updateSubcategory(subcategory);
      } else {
        await _firestoreService.addSubcategory(subcategory);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Subcategory updated successfully!' : 'Subcategory added successfully!'),
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
      backgroundColor: PurviVogueColors.softBeige,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Subcategory' : 'Add New Subcategory'),
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.roseGold,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PurviVogueColors.roseGold))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildCategorySection(),
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
            labelText: 'Subcategory Name *',
            hintText: 'Enter subcategory name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Subcategory name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Enter subcategory description',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _thumbnailUrlController,
          decoration: const InputDecoration(
            labelText: 'Thumbnail URL',
            hintText: 'Enter thumbnail image URL',
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return _buildSection(
      title: 'Parent Category',
      icon: Icons.category,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'Category *',
            hintText: 'Select a parent category',
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
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
            onPressed: _isLoading ? null : _saveSubcategory,
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
                : Text(widget.isEditing ? 'Update Subcategory' : 'Add Subcategory'),
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
