# Purvi Vogue Admin Panel Setup Guide

## Overview
The Purvi Vogue app now includes a secure admin panel with proper authentication and authorization. Only authenticated admin users can access the admin features.

## Features
- **Secure Authentication**: Email/password login with Firebase Auth
- **Admin Authorization**: Only users in the `admins` collection can access admin features
- **Modern UI**: Professional admin dashboard with sidebar navigation
- **Product Management**: Add, edit, and manage products with image uploads
- **Responsive Design**: Works on desktop and mobile devices

## Initial Setup

### 1. Firebase Configuration
Make sure your Firebase project is properly configured with:
- Authentication enabled (Email/Password sign-in method)
- Firestore database created
- Security rules configured

### 2. Create First Admin User
1. Run the app
2. Navigate to the landing page
3. Click "Admin Panel"
4. On the login screen, click "Setup Admin"
5. Fill in the admin details:
   - Full Name
   - Email
   - Password (minimum 6 characters)
   - Confirm Password
6. Click "Create Admin Account"

This will:
- Create a Firebase Auth user
- Add the user to the `admins` collection in Firestore
- Redirect you to the login screen

### 3. Login to Admin Panel
1. Use the email and password you just created
2. You'll be redirected to the admin dashboard

## Admin Panel Features

### Dashboard
- Overview of products, categories, and featured items
- Quick action buttons for common tasks
- Modern card-based layout with statistics

### Add Product
- Product name, description, category ID, and tags
- Multiple image upload support
- Real-time validation
- Cloudinary integration for image storage

### Navigation
- Sidebar navigation with icons
- Dashboard, Add Product, Products, Categories, Orders, Analytics
- Sign out functionality

## Security Features

### Authentication Flow
1. User enters email/password
2. Firebase Auth validates credentials
3. System checks if user exists in `admins` collection
4. If authorized, user can access admin features
5. If not authorized, user is signed out and shown error

### Protected Routes
- `/admin/dashboard` - Requires admin authentication
- `/admin/products` - Requires admin authentication
- All admin routes are wrapped with `AdminWrapper`

### Firestore Security Rules
Make sure your Firestore security rules include:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow admins to read/write all data
    match /{document=**} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    // Allow public read access to products and categories
    match /products/{productId} {
      allow read: if true;
    }
    
    match /categories/{categoryId} {
      allow read: if true;
    }
  }
}
```

## File Structure
```
lib/
├── services/
│   ├── auth_service.dart          # Authentication and authorization
│   ├── firestore_service.dart     # Firestore operations
│   └── cloudinary_service.dart    # Image upload service
├── ui/
│   ├── admin/
│   │   ├── admin_login_screen.dart    # Login screen
│   │   ├── admin_setup_screen.dart    # First-time setup
│   │   ├── admin_wrapper.dart         # Authentication wrapper
│   │   ├── dashboard_screen.dart      # Main admin dashboard
│   │   └── products_list_screen.dart  # Product management
│   └── user/
│       └── catalog_screen.dart        # Customer catalog
└── models/
    ├── product.dart                   # Product data model
    └── category.dart                  # Category data model
```

## Troubleshooting

### Common Issues

1. **"Access denied" error after login**
   - Make sure the user exists in the `admins` collection
   - Check Firestore security rules

2. **Image upload fails**
   - Verify Cloudinary configuration
   - Check upload preset and cloud name

3. **Firebase initialization error**
   - Ensure `firebase_options.dart` is properly configured
   - Check Firebase project settings

### Adding More Admin Users
1. Use the setup screen to create additional admin accounts
2. Or manually add users to the `admins` collection in Firestore

## Development Notes

- The admin panel uses Material Design 3
- All forms include proper validation
- Error handling with user-friendly messages
- Responsive design for different screen sizes
- Loading states for better UX

## Next Steps
- Add category management
- Implement order management
- Add analytics dashboard
- Create user management features
- Add bulk operations for products
