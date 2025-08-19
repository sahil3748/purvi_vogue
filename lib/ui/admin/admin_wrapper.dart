import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purvi_vogue/services/auth_service.dart';
import 'package:purvi_vogue/ui/admin/admin_login_screen.dart';
import 'package:purvi_vogue/ui/admin/dashboard_screen.dart';

class AdminWrapper extends StatefulWidget {
  final Widget child;
  
  const AdminWrapper({super.key, required this.child});

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final isAdmin = await _authService.isAdmin();
      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAdmin) {
      return const AdminLoginScreen();
    }

    return widget.child;
  }
}
