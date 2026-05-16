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
  final TextEditingController _idController = TextEditingController(); // NIC hari Student ID hari gahanna meka thamai use wenne

  bool _isLoading = false;
  String _selectedRole = 'student'; 

  final Color darkBlue = const Color(0xFF0A1D37);
  final Color premiumGreen = const Color(0xFF00C7BE);

  void _signup() async {
    if (_idController.text.trim().isEmpty) {
      _showError("Please enter your ${_selectedRole == 'student' ? 'Student ID' : 'NIC Number'}");
      return;
    }

    setState(() { _isLoading = true; });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Database eke data tika structure karanawa
      Map<String, dynamic> userData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole, 
        'walletBalance': 0.0,
      };

      // Role eka anuwa field name eka wenas karanawa
      if (_selectedRole == 'student') {
        userData['studentId'] = _idController.text.trim();
      } else {
        userData['nicNumber'] = _idController.text.trim(); // Driver ta NIC eka save wenawa
      }

      await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set(userData);

      if (mounted) {
        if (_selectedRole == 'driver') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverHomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StudentHomeScreen()));
        }
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
    setState(() { _isLoading = false; });
  }

  void _showError(String message) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Signup Failed'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))
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
            top: -100, right: -50,
            child: Container(width: 300, height: 300, decoration: BoxDecoration(color: darkBlue.withOpacity(0.1), shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: -50, left: -50,
            child: Container(width: 250, height: 250, decoration: BoxDecoration(color: premiumGreen.withOpacity(0.15), shape: BoxShape.circle)),
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
                      icon: Icon(CupertinoIcons.back, color: darkBlue, size: 28),
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
                        Text('Create Account', style: TextStyle(color: darkBlue, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        Text('Join NSBM Shuttle Community', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 30),

                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
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
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Text('Student', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _selectedRole == 'student' ? darkBlue : Colors.grey.shade500)),
                                    ),
                                    'driver': Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Text('Driver', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _selectedRole == 'driver' ? darkBlue : Colors.grey.shade500)),
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
                                  Expanded(child: _buildIosTextField(controller: _firstNameController, hint: 'First Name')),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildIosTextField(controller: _lastNameController, hint: 'Last Name')),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildIosTextField(controller: _usernameController, icon: CupertinoIcons.person_solid, hint: 'Username'),
                              const SizedBox(height: 15),
                              
                              // METHANA DAN NIC ILLANAWAA!
                              _buildIosTextField(
                                controller: _idController, 
                                icon: _selectedRole == 'student' ? CupertinoIcons.badge_plus_radiowaves_right : CupertinoIcons.doc_plaintext, 
                                hint: _selectedRole == 'student' ? 'Student ID' : 'NIC Number'
                              ),
                              const SizedBox(height: 15),
                              
                              _buildIosTextField(controller: _emailController, icon: CupertinoIcons.mail_solid, hint: 'Email Address'),
                              const SizedBox(height: 15),
                              
                              _buildIosTextField(controller: _passwordController, icon: CupertinoIcons.lock_fill, hint: 'Password', isPassword: true),

                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity, height: 60,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: premiumGreen,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLoading ? null : _signup,
                                  child: _isLoading 
                                    ? const CupertinoActivityIndicator(color: Colors.white)
                                    : const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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

  Widget _buildIosTextField({required TextEditingController controller, IconData? icon, required String hint, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: hint.contains('Email') ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(color: darkBlue, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade500, size: 20) : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: icon == null ? 20 : 0),
        ),
      ),
    );
  }
}