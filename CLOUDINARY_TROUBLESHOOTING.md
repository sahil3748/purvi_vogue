# 🔧 Cloudinary Troubleshooting Guide

## 🚨 "Unknown API Key" Error - Quick Fix

### Step 1: Check Your Cloudinary Dashboard
1. Go to [Cloudinary Dashboard](https://cloudinary.com/console)
2. Look at the top-left corner for your **Cloud Name**
3. Go to **Settings** → **Upload** → **Upload presets**
4. Verify your upload preset exists and is set to **"Unsigned"**

### Step 2: Configure Your App
Update your `lib/config/env_config.dart` with your actual values:

```dart
static const String cloudinaryCloudName = String.fromEnvironment(
  'CLOUDINARY_CLOUD_NAME',
  defaultValue: 'your_actual_cloud_name', // Replace with your cloud name
);

static const String cloudinaryUploadPreset = String.fromEnvironment(
  'CLOUDINARY_UPLOAD_PRESET',
  defaultValue: 'your_actual_upload_preset', // Replace with your upload preset name
);
```

### Step 3: Test Configuration
1. Run the app
2. Go to Admin Dashboard → **Test Cloudinary**
3. Click **Test Configuration**
4. Check the console output for detailed error messages

## 🔍 Common Issues & Solutions

### Issue 1: "Upload preset not found"
**Cause**: Upload preset doesn't exist or name is incorrect
**Solution**:
1. Go to Cloudinary Dashboard → Settings → Upload → Upload presets
2. Create a new upload preset:
   - Name: `purvi_vogue_uploads` (or your preferred name)
   - Signing Mode: **Unsigned** (very important!)
   - Folder: `purvi_vogue/products` (optional)
   - Allowed formats: Select image formats
   - Max file size: 10MB (or your preferred limit)
3. Copy the exact preset name to your configuration

### Issue 2: "Cloud name not found"
**Cause**: Cloud name is incorrect
**Solution**:
1. Check your Cloudinary dashboard for the exact cloud name
2. It's usually in the format: `dxxxxx` or `your-company-name`
3. Make sure there are no extra spaces or characters

### Issue 3: "Invalid upload preset"
**Cause**: Upload preset is set to "Signed" instead of "Unsigned"
**Solution**:
1. Go to Cloudinary Dashboard → Settings → Upload → Upload presets
2. Find your preset and click **Edit**
3. Change **Signing Mode** from "Signed" to **"Unsigned"**
4. Save the changes

### Issue 4: "File too large"
**Cause**: File exceeds upload preset limits
**Solution**:
1. Check your upload preset's file size limit
2. Either reduce the image size or increase the limit
3. Recommended limit: 10MB for product images

## 🛠️ Debug Steps

### 1. Use the Test Screen
The app now includes a Cloudinary test screen:
1. Go to Admin Dashboard
2. Click **"Test Cloudinary"**
3. This will show your current configuration
4. Test the configuration and try uploading

### 2. Check Console Output
When you try to upload, check the console for detailed debug information:
```
🔍 Cloudinary Debug Info:
   Cloud Name: your_cloud_name
   Upload Preset: your_upload_preset
   File Path: /path/to/image.jpg
   File Size: 1234567 bytes
   Upload URL: https://api.cloudinary.com/v1_1/your_cloud_name/image/upload
   Request Fields: {upload_preset: your_upload_preset}
   Response Status: 400
   Response Body: {"error":{"message":"Upload preset not found"}}
```

### 3. Manual API Test
You can test the API manually using curl:
```bash
curl -X POST \
  https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/image/upload \
  -F "upload_preset=YOUR_UPLOAD_PRESET" \
  -F "file=@test.jpg"
```

## 📋 Configuration Checklist

### ✅ Cloudinary Dashboard Setup
- [ ] Cloud name is correct
- [ ] Upload preset exists
- [ ] Upload preset is set to "Unsigned"
- [ ] Upload preset allows image formats
- [ ] File size limit is appropriate

### ✅ App Configuration
- [ ] Cloud name matches dashboard
- [ ] Upload preset name matches exactly
- [ ] No extra spaces or characters
- [ ] Configuration is loaded correctly

### ✅ Network & Permissions
- [ ] App has internet permission
- [ ] No firewall blocking uploads
- [ ] Cloudinary service is accessible

## 🚀 Quick Setup for Development

For quick testing, you can temporarily hardcode your values:

```dart
// In lib/config/env_config.dart (REMOVE BEFORE COMMITTING!)
static const String cloudinaryCloudName = String.fromEnvironment(
  'CLOUDINARY_CLOUD_NAME',
  defaultValue: 'your_actual_cloud_name', // Your real cloud name
);

static const String cloudinaryUploadPreset = String.fromEnvironment(
  'CLOUDINARY_UPLOAD_PRESET',
  defaultValue: 'your_actual_preset', // Your real upload preset
);
```

**⚠️ IMPORTANT**: Remove these hardcoded values before committing to version control!

## 🔒 Production Setup

For production, use environment variables:

```bash
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name --dart-define=CLOUDINARY_UPLOAD_PRESET=your_preset
```

## 📞 Still Having Issues?

If you're still getting errors:

1. **Check the exact error message** in the console
2. **Verify your Cloudinary account** is active
3. **Test with a simple image** (small JPG file)
4. **Check Cloudinary status** at [status.cloudinary.com](https://status.cloudinary.com)
5. **Review Cloudinary documentation** for upload presets

## 🎯 Expected Behavior

When everything is configured correctly:
1. Test Configuration should show ✅
2. Image upload should complete successfully
3. You should get a Cloudinary URL back
4. Image should appear in your Cloudinary media library

---

**Remember**: The key is using **unsigned uploads** with upload presets, not API keys!
