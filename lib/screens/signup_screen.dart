import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'student_home_screen.dart';
import 'driver_home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  bool _isLoading = false;
  String _selectedRole = 'student';

  final Color darkBlue = const Color(0xFF0A1D37);
  final Color premiumGreen = const Color(0xFF00C7BE);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _signup() async {
    try {
      // Comprehensive validation
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String id = _idController.text.trim();

      // Validate first name
      if (firstName.isEmpty || firstName.length < 2) {
        _showError('First name must be at least 2 characters');
        return;
      }

      // Validate last name
      if (lastName.isEmpty || lastName.length < 2) {
        _showError('Last name must be at least 2 characters');
        return;
      }

      // Validate username
      if (username.isEmpty || username.length < 3 || username.length > 20) {
        _showError('Username must be 3-20 characters');
        return;
      }
      if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
        _showError('Username can only contain letters, numbers, - and _');
        return;
      }

      // Validate email
      if (email.isEmpty ||
          !RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          ).hasMatch(email)) {
        _showError('Please enter a valid email address');
        return;
      }

      // Validate password
      if (password.isEmpty || password.length < 8) {
        _showError('Password must be at least 8 characters');
        return;
      }
      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        _showError('Password must contain an uppercase letter');
        return;
      }
      if (!RegExp(r'[0-9]').hasMatch(password)) {
        _showError('Password must contain a number');
        return;
      }

      // Validate ID
      if (id.isEmpty || id.length < 3) {
        _showError(
          "Please enter your ${_selectedRole == 'student' ? 'Student ID' : 'NIC Number'}",
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final userId = userCredential.user?.uid;

      if (userId == null) {
        throw Exception('Failed to create user account');
      }

      // Database eke data tika structure karanawa
      final userData = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'role': _selectedRole,
        'walletBalance': 0.0,
      };

      // Role eka anuwa field name eka wenas karanawa
      if (_selectedRole == 'student') {
        userData['studentId'] = id;
      } else {
        userData['nicNumber'] = id;
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .set(userData);

      if (mounted) {
        if (_selectedRole == 'driver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
          );
        }
      }
    } catch (e) {
      String errorMessage = _getSignupErrorMessage(e);
      _showError(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  String _getSignupErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'Password is too weak. Use uppercase, numbers, and special characters.';
        case 'email-already-in-use':
          return 'Email already in use. Please use a different email.';
        case 'invalid-email':
          return 'Invalid email format. Please try again.';
        case 'operation-not-allowed':
          return 'Sign up is currently disabled. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return 'Sign up failed. Please try again.';
      }
    } else if (e is Exception) {
      final message = e.toString().replaceAll('Exception: ', '');
      return message;
    }
    return 'An unexpected error occurred.';
  }

  void _showError(String message) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Signup Failed'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF2F2F7), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: darkBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: premiumGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.back,
                        color: darkBlue,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join NSBM Shuttle Community',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),

                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoSlidingSegmentedControl<String>(
                                  backgroundColor: const Color(0xFFF2F2F7),
                                  thumbColor: Colors.white,
                                  groupValue: _selectedRole,
                                  padding: const EdgeInsets.all(4),
                                  children: {
                                    'student': Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        'Student',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: _selectedRole == 'student'
                                              ? darkBlue
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                    'driver': Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        'Driver',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: _selectedRole == 'driver'
                                              ? darkBlue
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  },
                                  onValueChanged: (value) {
                                    setState(() {
                                      _selectedRole = value!;
                                      _idController.clear();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 25),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildIosTextField(
                                      controller: _firstNameController,
                                      hint: 'First Name',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildIosTextField(
                                      controller: _lastNameController,
                                      hint: 'Last Name',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildIosTextField(
                                controller: _usernameController,
                                icon: CupertinoIcons.person_solid,
                                hint: 'Username',
                              ),
                              const SizedBox(height: 15),

                              // METHANA DAN NIC ILLANAWAA!
                              _buildIosTextField(
                                controller: _idController,
                                icon: _selectedRole == 'student'
                                    ? CupertinoIcons.badge_plus_radiowaves_right
                                    : CupertinoIcons.doc_plaintext,
                                hint: _selectedRole == 'student'
                                    ? 'Student ID'
                                    : 'NIC Number',
                              ),
                              const SizedBox(height: 15),

                              _buildIosTextField(
                                controller: _emailController,
                                icon: CupertinoIcons.mail_solid,
                                hint: 'Email Address',
                              ),
                              const SizedBox(height: 15),

                              _buildIosTextField(
                                controller: _passwordController,
                                icon: CupertinoIcons.lock_fill,
                                hint: 'Password',
                                isPassword: true,
                              ),

                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: premiumGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLoading ? null : _signup,
                                  child: _isLoading
                                      ? const CupertinoActivityIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIosTextField({
    required TextEditingController controller,
    IconData? icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: hint.contains('Email')
            ? TextInputType.emailAddress
            : TextInputType.text,
        style: TextStyle(color: darkBlue, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.grey.shade500, size: 20)
              : null,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 18,
            horizontal: icon == null ? 20 : 0,
          ),
        ),
      ),
    );
  }
}

