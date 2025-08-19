import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  Future<String> uploadImage({
    required File file,
    required String cloudName,
    required String uploadPreset,
    Map<String, String>? extraFields,
  }) async {
    try {
      // Debug information
      print('🔍 Cloudinary Debug Info:');
      print('   Cloud Name: $cloudName');
      print('   Upload Preset: $uploadPreset');
      print('   File Path: ${file.path}');
      print('   File Size: ${await file.length()} bytes');

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      print('   Upload URL: $uri');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      if (extraFields != null) {
        request.fields.addAll(extraFields);
      }

      print('   Request Fields: ${request.fields}');

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      
      print('   Response Status: ${response.statusCode}');
      print('   Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final secureUrl = body['secure_url'] as String?;
        if (secureUrl == null || secureUrl.isEmpty) {
          throw Exception('Cloudinary response missing secure_url');
        }
        print('   ✅ Upload successful: $secureUrl');
        return secureUrl;
      } else {
        // Enhanced error handling
        final errorBody = response.body;
        print('   ❌ Upload failed with status ${response.statusCode}');
        print('   Error details: $errorBody');
        
        // Parse error message for better debugging
        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          final errorMessage = errorJson['error']?['message'] ?? 'Unknown error';
          throw Exception('Cloudinary upload failed: $errorMessage');
        } catch (e) {
          throw Exception('Cloudinary upload failed (${response.statusCode}): $errorBody');
        }
      }
    } catch (e) {
      print('   ❌ Exception during upload: $e');
      rethrow;
    }
  }

  // Helper method to test configuration
  Future<bool> testConfiguration({
    required String cloudName,
    required String uploadPreset,
  }) async {
    try {
      print('🧪 Testing Cloudinary Configuration...');
      print('   Cloud Name: $cloudName');
      print('   Upload Preset: $uploadPreset');
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['test'] = '1'; // Test parameter

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      
      print('   Test Response Status: ${response.statusCode}');
      print('   Test Response Body: ${response.body}');
      
      return response.statusCode != 400; // 400 usually means invalid preset
    } catch (e) {
      print('   ❌ Configuration test failed: $e');
      return false;
    }
  }
}


