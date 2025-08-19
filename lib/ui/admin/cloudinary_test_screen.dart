import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purvi_vogue/config/cloudinary_config.dart';
import 'package:purvi_vogue/services/cloudinary_service.dart';

class CloudinaryTestScreen extends StatefulWidget {
  const CloudinaryTestScreen({super.key});

  @override
  State<CloudinaryTestScreen> createState() => _CloudinaryTestScreenState();
}

class _CloudinaryTestScreenState extends State<CloudinaryTestScreen> {
  final _cloudinary = CloudinaryService();
  final _imagePicker = ImagePicker();
  bool _isTesting = false;
  bool _isUploading = false;
  String _testResult = '';
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cloudinary Test'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuration Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Configuration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildConfigItem('Cloud Name', CloudinaryConfig.cloudName),
                    _buildConfigItem('Upload Preset', CloudinaryConfig.uploadPreset),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Configuration Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _testConfiguration,
                icon: _isTesting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.science),
                label: Text(_isTesting ? 'Testing...' : 'Test Configuration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Result
            if (_testResult.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _testResult.contains('✅') 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _testResult.contains('✅') 
                        ? Colors.green.shade200 
                        : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _testResult,
                  style: TextStyle(
                    color: _testResult.contains('✅') 
                        ? Colors.green.shade800 
                        : Colors.red.shade800,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Image Upload Test
            Text(
              'Image Upload Test',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Image Selection
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedImage != null && !_isUploading 
                        ? _uploadImage 
                        : null,
                    icon: _isUploading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selected Image Preview
            if (_selectedImage != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not configured' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.red : Colors.black,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConfiguration() async {
    setState(() {
      _isTesting = true;
      _testResult = '';
    });

    try {
      final isValid = await _cloudinary.testConfiguration(
        cloudName: CloudinaryConfig.cloudName,
        uploadPreset: CloudinaryConfig.uploadPreset,
      );

      setState(() {
        _testResult = isValid 
            ? '✅ Configuration is valid! You can proceed with uploads.'
            : '❌ Configuration is invalid. Please check your cloud name and upload preset.';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Test failed: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _testResult = '';
    });

    try {
      final url = await _cloudinary.uploadImage(
        file: _selectedImage!,
        cloudName: CloudinaryConfig.cloudName,
        uploadPreset: CloudinaryConfig.uploadPreset,
      );

      setState(() {
        _testResult = '✅ Upload successful!\nURL: $url';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Upload failed: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
