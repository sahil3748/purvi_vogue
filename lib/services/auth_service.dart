import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
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
