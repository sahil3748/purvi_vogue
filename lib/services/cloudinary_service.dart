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
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final secureUrl = body['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Cloudinary response missing secure_url');
      }
      return secureUrl;
    }
    throw Exception('Cloudinary upload failed (${response.statusCode}): ${response.body}');
  }
}


