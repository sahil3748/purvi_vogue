import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/luxury_theme.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/category_options.dart';
import 'package:purvi_vogue/services/firestore_service.dart';

class CategoryOptionsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryOptionsScreen({super.key, required this.category});

  @override
  State<CategoryOptionsScreen> createState() => _CategoryOptionsScreenState();
}

class _CategoryOptionsScreenState extends State<CategoryOptionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isEditing = false;
  CategoryOptionsModel? _existingOptions;
  
  // Controllers for adding new options
  final _materialController = TextEditingController();
  final _sizeController = TextEditingController();
  final _weightController = TextEditingController();
  final _genderController = TextEditingController();
  final _colorController = TextEditingController();
  final _occasionController = TextEditingController();
  
  // Lists to hold current options
  List<String> _materials = [];
  List<String> _sizes = [];
  List<String> _weights = [];
  List<String> _genders = [];
  List<String> _colors = [];
  List<String> _occasions = [];

  @override
  void initState() {
    super.initState();
    _loadExistingOptions();
  }

  Future<void> _loadExistingOptions() async {
    setState(() => _isLoading = true);
    try {
      final options = await _firestoreService.getCategoryOptions(widget.category.id);
      if (options != null) {
        setState(() {
          _isEditing = true;
          _existingOptions = options;
          _materials = List.from(options.materials);
          _sizes = List.from(options.sizes);
          _weights = List.from(options.weights);
          _genders = List.from(options.genders);
          _colors = List.from(options.colors);
          _occasions = List.from(options.occasions);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading options: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOptions() async {
    setState(() => _isLoading = true);
    try {
      final options = CategoryOptionsModel(
        id: _existingOptions?.id ?? '',
        categoryId: widget.category.id,
        materials: _materials,
        sizes: _sizes,
        weights: _weights,
        genders: _genders,
        colors: _colors,
        occasions: _occasions,
        createdAt: _existingOptions?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing && _existingOptions != null) {
        await _firestoreService.updateCategoryOptions(options);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Options updated successfully')),
          );
        }
      } else {
        await _firestoreService.addCategoryOptions(options);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Options added successfully')),
          );
        }
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving options: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addOption(String type, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return;

    setState(() {
      switch (type) {
        case 'materials':
          if (!_materials.contains(value)) _materials.add(value);
          break;
        case 'sizes':
          if (!_sizes.contains(value)) _sizes.add(value);
          break;
        case 'weights':
          if (!_weights.contains(value)) _weights.add(value);
          break;
        case 'genders':
          if (!_genders.contains(value)) _genders.add(value);
          break;
        case 'colors':
          if (!_colors.contains(value)) _colors.add(value);
          break;
        case 'occasions':
          if (!_occasions.contains(value)) _occasions.add(value);
          break;
      }
    });
    controller.clear();
  }

  void _removeOption(String type, String value) {
    setState(() {
      switch (type) {
        case 'materials':
          _materials.remove(value);
          break;
        case 'sizes':
          _sizes.remove(value);
          break;
        case 'weights':
          _weights.remove(value);
          break;
        case 'genders':
          _genders.remove(value);
          break;
        case 'colors':
          _colors.remove(value);
          break;
        case 'occasions':
          _occasions.remove(value);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.name} Options'),
        backgroundColor: PurviVogueColors.warmGold,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage options for ${widget.category.name} category',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildOptionSection('Materials', _materials, _materialController, 'materials'),
                    const SizedBox(height: 24),
                    _buildOptionSection('Sizes', _sizes, _sizeController, 'sizes'),
                    const SizedBox(height: 24),
                    _buildOptionSection('Weights', _weights, _weightController, 'weights'),
                    const SizedBox(height: 24),
                    _buildOptionSection('Genders', _genders, _genderController, 'genders'),
                    const SizedBox(height: 24),
                    _buildOptionSection('Colors', _colors, _colorController, 'colors'),
                    const SizedBox(height: 24),
                    _buildOptionSection('Occasions', _occasions, _occasionController, 'occasions'),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOptionSection(String title, List<String> options, TextEditingController controller, String type) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Add $title',
                      border: const OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addOption(type, controller),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addOption(type, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PurviVogueColors.warmGold,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (options.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: options.map((option) {
                  return Chip(
                    label: Text(option),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeOption(type, option),
                    backgroundColor: PurviVogueColors.warmGold.withOpacity(0.1),
                    deleteIconColor: PurviVogueColors.deepNavy,
                  );
                }).toList(),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  'No $title added yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveOptions,
        style: ElevatedButton.styleFrom(
          backgroundColor: PurviVogueColors.warmGold,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                _isEditing ? 'Update Options' : 'Save Options',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _materialController.dispose();
    _sizeController.dispose();
    _weightController.dispose();
    _genderController.dispose();
    _colorController.dispose();
    _occasionController.dispose();
    super.dispose();
  }
}
