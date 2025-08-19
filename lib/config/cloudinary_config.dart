import 'env_config.dart';

class CloudinaryConfig {
  // Cloudinary Configuration for Secure Uploads
  // Using unsigned uploads with upload preset (recommended for client-side apps)
  
  // Your Cloudinary cloud name (found in your Cloudinary dashboard)
  static const String cloudName = EnvConfig.cloudinaryCloudName;
  
  // Your unsigned upload preset (create this in Cloudinary dashboard)
  static const String uploadPreset = EnvConfig.cloudinaryUploadPreset;
  
  // Note: Never use API keys in client-side applications
  // This configuration uses unsigned uploads which is secure for client apps
}


