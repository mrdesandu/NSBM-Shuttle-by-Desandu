import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'student_home_screen.dart';
import 'driver_home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Premium iOS Colors
  final Color darkBlue = const Color(0xFF0A1D37);
  final Color premiumGreen = const Color(0xFF00C7BE);

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String inputUsername = _usernameController.text.trim();
      String inputPassword = _passwordController.text.trim();

      if (inputUsername.isEmpty || inputPassword.isEmpty) {
        throw Exception("Please enter both Username and Password.");
      }

      // 1. Username එක database එකෙන් හොයනවා
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: inputUsername)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception("Username not found! Please check again or Sign Up.");
      }

      // 2. Data එක ගන්න කලින් ඒකේ 'email' තියෙනවද කියලා බලනවා (පරණ accounts වලදී crash වෙන්නෙ නැති වෙන්න)
      var userData = userQuery.docs.first.data() as Map<String, dynamic>;

      if (!userData.containsKey('email') ||
          userData['email'].toString().isEmpty) {
        throw Exception(
          "This is an old account. Please create a New Account with a DIFFERENT username.",
        );
      }

      String userEmail = userData['email'];
      String role = userData['role'] ?? 'student';

      // 3. Firebase login වෙනවා
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: inputPassword,
      );

      // 4. Role එක අනුව Screen එකට යනවා
      if (mounted) {
        if (role == 'driver') {
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
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- BACKGROUND GRADIENT ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF2F2F7), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // --- BACKGROUND DECORATION (Blurry Orbs) ---
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: premiumGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: darkBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- FROSTED GLASS OVERLAY ---
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),

          // --- MAIN CONTENT ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: premiumGreen.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.bus,
                        size: 50,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue to NSBM Shuttle',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- INPUT CARD ---
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildIosTextField(
                            controller: _usernameController,
                            icon: CupertinoIcons.person_solid,
                            hint: 'Username',
                          ),
                          const SizedBox(height: 15),
                          _buildIosTextField(
                            controller: _passwordController,
                            icon: CupertinoIcons.lock_fill,
                            hint: 'Password',
                            isPassword: true,
                          ),

                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: premiumGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // SIGN IN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const CupertinoActivityIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Sign In',
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

                    // SIGN UP LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: premiumGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIosTextField({
    required TextEditingController controller,
    required IconData icon,
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
        style: TextStyle(color: darkBlue, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
