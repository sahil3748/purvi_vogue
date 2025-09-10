import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // SharedPreferences keys
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _isAdminKey = 'is_admin';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in (from persistent storage)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    // Also check if Firebase user is still valid
    if (isLoggedIn && _auth.currentUser != null) {
      return true;
    }
    
    // Clear stored data if Firebase user is null but we think we're logged in
    if (isLoggedIn && _auth.currentUser == null) {
      await _clearLoginData();
      return false;
    }
    
    return false;
  }

  // Get stored user email
  Future<String?> getStoredUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Check if stored user is admin
  Future<bool> isStoredUserAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminKey) ?? false;
  }

  // Store login data
  Future<void> _storeLoginData(String email, bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
    await prefs.setBool(_isAdminKey, isAdmin);
  }

  // Clear login data
  Future<void> _clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_isAdminKey);
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final doc = await _firestore.collection('admins').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    
    // Check if user is admin and store login data
    final isAdminUser = await isAdmin();
    if (isAdminUser) {
      await _storeLoginData(email, true);
    }
    
    return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearLoginData();
  }

  // Create admin user (for initial setup)
  Future<void> createAdminUser(String email, String password, String name) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await _firestore.collection('admins').doc(userCredential.user!.uid).set({
      'email': email,
      'name': name,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
