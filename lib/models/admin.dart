import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String uid;
  final String email;
  final String role; // "super_admin", "admin", etc.

  AdminModel({
    required this.uid,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
    };
  }

  factory AdminModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AdminModel(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
