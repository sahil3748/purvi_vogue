# 🔐 Cloudinary Secure Setup Guide

## Overview
This guide explains how to securely configure Cloudinary for image uploads in the Purvi Vogue Flutter application.

## ⚠️ Security Notice
**NEVER commit API keys or secrets to version control!** The current implementation uses unsigned uploads, which is the secure approach for client-side applications.

## 🚀 Setup Steps

### 1. Get Your Cloudinary Cloud Name
1. Log in to your [Cloudinary Dashboard](https://cloudinary.com/console)
2. Your cloud name is displayed in the top-left corner of the dashboard
3. It looks like: `dxxxxx` or `your-company-name`

### 2. Create an Upload Preset
1. In your Cloudinary Dashboard, go to **Settings** → **Upload**
2. Scroll down to **Upload presets**
3. Click **Add upload preset**
4. Configure the preset:
   - **Preset name**: Choose a name (e.g., `purvi_vogue_uploads`)
   - **Signing Mode**: Select **Unsigned** (this is crucial for security)
   - **Folder**: Set to `purvi_vogue/products` (optional)
   - **Allowed formats**: Select image formats you want to allow
   - **Max file size**: Set appropriate limit (e.g., 10MB)
5. Click **Save**

### 3. Configure the Application

#### Option A: Environment Variables (Recommended for Production)
Create a `.env` file in your project root (this file is already in .gitignore):

```bash
# .env file
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_UPLOAD_PRESET=your_upload_preset_name_here
```

Then run the app with:
```bash
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name_here --dart-define=CLOUDINARY_UPLOAD_PRESET=your_upload_preset_name_here
```

#### Option B: Direct Configuration (Development Only)
For development, you can temporarily update `lib/config/env_config.dart`:

```dart
static const String cloudinaryCloudName = String.fromEnvironment(
  'CLOUDINARY_CLOUD_NAME',
  defaultValue: 'your_actual_cloud_name', // Replace with your cloud name
);

static const String cloudinaryUploadPreset = String.fromEnvironment(
  'CLOUDINARY_UPLOAD_PRESET',
  defaultValue: 'your_actual_upload_preset', // Replace with your upload preset
);
```

**⚠️ Remember to revert this before committing to version control!**

### 4. Test the Configuration
1. Run the application
2. Go to Admin Dashboard → Add Product
3. Try uploading an image
4. Check if the image appears in your Cloudinary media library

## 🔒 Security Best Practices

### ✅ What's Secure (Current Implementation)
- **Unsigned uploads**: Uses upload presets instead of API keys
- **Client-side only**: No server-side code needed
- **Environment variables**: Credentials not hardcoded
- **Gitignore protection**: Sensitive files excluded from version control

### ❌ What to Avoid
- Never use API keys in client-side code
- Never commit credentials to version control
- Don't use signed uploads for client applications
- Avoid hardcoding cloud names in source code

## 🛠️ Troubleshooting

### Common Issues

1. **"Upload preset not found"**
   - Check that the upload preset name is correct
   - Ensure the preset is set to "Unsigned" mode
   - Verify the preset is active

2. **"Cloud name not found"**
   - Double-check your cloud name in the Cloudinary dashboard
   - Ensure there are no extra spaces or characters

3. **"Upload failed"**
   - Check file size limits in your upload preset
   - Verify allowed file formats
   - Check network connectivity

### Debug Mode
To debug upload issues, check the console logs when uploading images. The Cloudinary service will show detailed error messages.

## 📱 Production Deployment

For production deployment:

1. **Use environment variables** for all credentials
2. **Set up proper CORS** in your Cloudinary settings
3. **Configure upload presets** with appropriate restrictions
4. **Monitor usage** through Cloudinary dashboard
5. **Set up backup** and recovery procedures

## 🔄 Updating Configuration

To update Cloudinary settings:

1. Modify the upload preset in Cloudinary dashboard
2. Update environment variables if needed
3. Test thoroughly before deploying
4. Monitor for any issues after deployment

## 📞 Support

If you encounter issues:
1. Check Cloudinary documentation
2. Review error messages in console
3. Verify configuration settings
4. Test with a simple image upload

---

**Remember**: Security is paramount. Always use unsigned uploads and never expose API keys in client-side applications!
