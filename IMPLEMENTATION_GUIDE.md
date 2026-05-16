# NSBM Shuttle - Step-by-Step Implementation Guide

## PART 1: CREATE NEW CORE FILES

### Step 1.1: Create AppColors Constants File

**File:** `lib/core/constants/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Private constructor
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF00754A);
  static const Color primaryDark = Color(0xFF0A1D37);
  static const Color primaryLight = Color(0xFF00C7BE);
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF142850);
  static const Color gradientEnd = Color(0xFF0A1D37);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF2196F3);
  
  // Background & Surface
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEFEFF4);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0A1D37);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);
  
  // Neutral
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x00000014);
  
  // Overlay
  static const Color overlay = Color(0x3D000000);
}
```

---

### Step 1.2: Create AppConstants File

**File:** `lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  // Private constructor
  AppConstants._();

  // ===== PRICING =====
  static const double busTicketPrice = 120.0;
  static const double minWalletBalance = 10.0;
  static const double maxWalletBalance = 10000.0;
  static const double minimumAddAmount = 100.0;
  static const double maximumAddAmount = 5000.0;

  // ===== TIMEOUTS =====
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 15);
  static const Duration sessionTimeout = Duration(minutes: 15);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // ===== LOCATION COORDINATES =====
  static const double nsbmLatitude = 6.8213;
  static const double nsbmLongitude = 80.0416;
  static const double mapZoom = 14.4746;
  static const double mapZoomStudent = 14.0;

  // ===== VALIDATION =====
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 8;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // ===== PAGINATION =====
  static const int pageSize = 10;
  static const int maxRetries = 3;

  // ===== FIRESTORE COLLECTIONS =====
  static const String usersCollection = 'Users';
  static const String paymentsCollection = 'Payments';
  static const String busesCollection = 'Busses';
  static const String tripsCollection = 'Trips';
  static const String transactionsCollection = 'Transactions';
  static const String routesCollection = 'Routes';

  // ===== USER ROLES =====
  static const String roleStudent = 'student';
  static const String roleDriver = 'driver';

  // ===== ROUTES =====
  static const List<String> availableRoutes = [
    'Makumbura (MMC)',
    'Colombo Fort',
    'NSBM Green University',
  ];

  // ===== ERROR MESSAGES =====
  static const String errorNetworkConnection = 'Network connection failed. Please check your internet.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorGeneric = 'Something went wrong. Please try again later.';
  static const String errorInvalidInput = 'Please check your input and try again.';
  static const String errorUnauthorized = 'You are not authorized to perform this action.';
  static const String errorUserNotFound = 'User not found.';
}
```

---

### Step 1.3: Create App Theme File

**File:** `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        error: AppColors.error,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -1,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        headlineSmall: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
```

---

### Step 1.4: Create Logger Utility

**File:** `lib/core/utils/logger.dart`

```dart
import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _prefix = '[NSBM_SHUTTLE]';

  /// Log debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_prefix [DEBUG] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// Log info message
  static void info(String message) {
    if (kDebugMode) {
      print('$_prefix [INFO] $message');
    }
  }

  /// Log warning message
  static void warning(String message, [dynamic error]) {
    if (kDebugMode) {
      print('$_prefix [WARNING] $message');
      if (error != null) {
        print('Details: $error');
      }
    }
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_prefix [ERROR] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// Log exception with stack trace
  static void exception(String context, Object exception, StackTrace stackTrace) {
    error('Exception in $context: $exception', exception, stackTrace);
  }
}
```

---

### Step 1.5: Create Input Validators

**File:** `lib/core/utils/validators.dart`

```dart
class Validators {
  Validators._();

  // ===== USERNAME VALIDATION =====
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must not exceed 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, - and _';
    }
    return null;
  }

  // ===== EMAIL VALIDATION =====
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ===== PASSWORD VALIDATION =====
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain a special character (!@#\$%^&*)';
    }
    return null;
  }

  // ===== NAME VALIDATION =====
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens and apostrophes';
    }
    return null;
  }

  // ===== STUDENT ID VALIDATION =====
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Student ID is required';
    }
    if (value.length < 3) {
      return 'Student ID must be at least 3 characters';
    }
    return null;
  }

  // ===== NIC VALIDATION =====
  static String? validateNic(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIC is required';
    }
    // Sri Lankan NIC format validation
    const pattern = r'^\d{9}[V|X|v|x]$';
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Please enter a valid NIC (e.g., 123456789V)';
    }
    return null;
  }

  // ===== INPUT SANITIZATION =====
  static String sanitizeInput(String input) {
    // Remove HTML/script tags
    String sanitized = input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[;\"\'\\]'), '')
        .trim();
    
    // Remove multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    return sanitized;
  }
}
```

---

### Step 1.6: Create Reusable IosTextField Widget

**File:** `lib/widgets/ios_text_field.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';

class IosTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData? icon;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const IosTextField({
    Key? key,
    required this.controller,
    this.icon,
    required this.hint,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  State<IosTextField> createState() => _IosTextFieldState();
}

class _IosTextFieldState extends State<IosTextField> {
  late FocusNode _focusNode;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.isPassword && !_isPasswordVisible,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                color: Colors.grey.shade500,
                size: 20,
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? CupertinoIcons.eye_solid
                      : CupertinoIcons.eye_slash,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
```

---

### Step 1.7: Create Session Manager

**File:** `lib/core/utils/session_manager.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  
  DateTime? _lastActivityTime;
  VoidCallback? _onSessionExpired;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  /// Record user activity
  void recordActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Check if session has expired
  bool isSessionExpired() {
    if (_lastActivityTime == null) return false;
    
    final timeSinceLastActivity = DateTime.now().difference(_lastActivityTime!);
    return timeSinceLastActivity > AppConstants.sessionTimeout;
  }

  /// Get time remaining before session expires
  Duration getTimeRemaining() {
    if (_lastActivityTime == null) return Duration.zero;
    
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining = AppConstants.sessionTimeout - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Set callback for when session expires
  void setOnSessionExpired(VoidCallback callback) {
    _onSessionExpired = callback;
  }

  /// Trigger session expiration
  void expireSession() {
    _lastActivityTime = null;
    _onSessionExpired?.call();
  }

  /// Clear session
  void clearSession() {
    _lastActivityTime = null;
    _onSessionExpired = null;
  }
}
```

---

## PART 2: FIX EXISTING FILES

### Step 2.1: Fix LoginScreen

Replace the entire `_LoginScreenState` class in [lib/screens/login_screen.dart](lib/screens/login_screen.dart):

**Key Changes:**
1. Add `dispose()` for controllers
2. Add input validation
3. Add better error handling
4. Use new IosTextField

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/validators.dart';
import '../core/utils/logger.dart';
import '../widgets/ios_text_field.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final inputUsername = _usernameController.text.trim();
      final inputPassword = _passwordController.text.trim();

      AppLogger.info('Attempting login for user: $inputUsername');

      // 1. Query username in database
      final QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: inputUsername)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception("Username not found! Please check again or Sign Up.");
      }

      // 2. Validate user data
      final userData = userQuery.docs.first.data() as Map<String, dynamic>;

      if (!userData.containsKey('email') ||
          (userData['email'] as String?)?.isEmpty ?? true) {
        throw Exception(
          "This is an old account. Please create a New Account with a DIFFERENT username.",
        );
      }

      final userEmail = userData['email'] as String;
      final role = userData['role'] as String? ?? AppConstants.roleStudent;

      // 3. Firebase authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: inputPassword,
      );

      AppLogger.info('Login successful for user: $inputUsername (Role: $role)');

      // 4. Navigate based on role
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => role == AppConstants.roleDriver
                ? const DriverHomeScreen()
                : const StudentHomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase Auth Error: ${e.code}', e);
      setState(() {
        _errorMessage = _getAuthErrorMessage(e);
      });
      _showErrorDialog(_errorMessage!);
    } catch (e) {
      AppLogger.error('Login Error', e);
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _showErrorDialog(_errorMessage!);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Username not found. Please check or sign up for a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Login Failed'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF2F2F7), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Decorative orbs
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
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
                color: AppColors.primaryDark.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Frosted glass effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          CupertinoIcons.bus,
                          size: 50,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryDark,
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

                      // Input card
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
                            IosTextField(
                              controller: _usernameController,
                              icon: CupertinoIcons.person_solid,
                              hint: 'Username',
                              validator: Validators.validateUsername,
                            ),
                            const SizedBox(height: 15),
                            IosTextField(
                              controller: _passwordController,
                              icon: CupertinoIcons.lock_fill,
                              hint: 'Password',
                              isPassword: true,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
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

                      // Sign Up Link
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
                                color: AppColors.primaryLight,
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
          ),
        ],
      ),
    );
  }
}
```

---

### Step 2.2: Fix SignupScreen

Similar structure to LoginScreen fix. Key additions:
1. Add `dispose()` for all 6 controllers
2. Add comprehensive input validation
3. Add input sanitization
4. Use new IosTextField
5. Better error handling

```dart
// lib/screens/signup_screen.dart

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

Future<void> _signup() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Sanitize all inputs
    final firstName = Validators.sanitizeInput(_firstNameController.text);
    final lastName = Validators.sanitizeInput(_lastNameController.text);
    final username = Validators.sanitizeInput(_usernameController.text);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final id = _idController.text.trim();

    AppLogger.info('Attempting signup for username: $username');

    // Check if user already exists
    final existingUser = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (existingUser.docs.isNotEmpty) {
      throw Exception('This username is already taken. Please choose another.');
    }

    // Create Firebase auth account
    final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception('Failed to create account. Please try again.');
    }

    // Prepare user data
    Map<String, dynamic> userData = {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'role': _selectedRole,
      'walletBalance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
    };

    if (_selectedRole == AppConstants.roleStudent) {
      userData['studentId'] = id;
    } else {
      userData['nicNumber'] = id;
    }

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userCredential.user!.uid)
        .set(userData);

    AppLogger.info('Signup successful for username: $username');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => _selectedRole == AppConstants.roleDriver
              ? const DriverHomeScreen()
              : const StudentHomeScreen(),
        ),
        (route) => false,
      );
    }
  } on FirebaseAuthException catch (e) {
    AppLogger.error('Firebase Auth Error: ${e.code}', e);
    _showError(_getSignupAuthError(e));
  } catch (e) {
    AppLogger.error('Signup Error', e);
    _showError(e.toString().replaceAll('Exception: ', ''));
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

String _getSignupAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'weak-password':
      return 'Password is too weak. Use 8+ chars with uppercase, numbers, and symbols.';
    case 'email-already-in-use':
      return 'This email is already registered. Please login.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'operation-not-allowed':
      return 'Signup is currently disabled. Please try again later.';
    case 'too-many-requests':
      return 'Too many signup attempts. Please try again later.';
    default:
      return 'Signup failed: ${e.message}';
  }
}
```

---

### Step 2.3: Fix DriverScannerScreen - Payment Transaction Atomicity

Replace the `_processPayment` method:

```dart
Future<void> _processPayment(String studentId) async {
  if (_isProcessing) return;

  setState(() => _isProcessing = true);
  cameraController.stop();

  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Use Firestore transaction for atomicity
    await firestore.runTransaction((transaction) async {
      final studentRef = firestore
          .collection(AppConstants.usersCollection)
          .doc(studentId);
      
      final snapshot = transaction.get(studentRef);

      if (!snapshot.exists) {
        throw Exception('Student not found');
      }

      final data = snapshot.data() as Map<String, dynamic>;

      // Validate student role
      if (data['role'] != AppConstants.roleStudent) {
        throw Exception('This is not a valid student account');
      }

      final studentName = data['username'] as String? ?? 'Unknown';
      final currentBalance = (data['walletBalance'] as num? ?? 0.0).toDouble();

      // Check balance
      if (currentBalance < AppConstants.busTicketPrice) {
        throw InsufficientBalanceException(
          'Insufficient balance',
          currentBalance,
        );
      }

      // Create payment record
      final paymentRef = firestore.collection(AppConstants.paymentsCollection).doc();
      transaction.set(paymentRef, {
        'studentId': studentId,
        'studentName': studentName,
        'amount': AppConstants.busTicketPrice,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'paymentId': paymentRef.id,
      });

      // Deduct balance in same transaction
      final newBalance = currentBalance - AppConstants.busTicketPrice;
      transaction.update(studentRef, {
        'walletBalance': newBalance,
        'lastTransaction': FieldValue.serverTimestamp(),
      });

      // Show success dialog
      if (mounted) {
        _showIosPopup(true, studentName, newBalance);
      }
    });
  } on InsufficientBalanceException catch (e) {
    AppLogger.warning('Insufficient balance: $e');
    if (mounted) {
      _showIosPopup(false, e.studentName, e.currentBalance);
    }
  } catch (e) {
    AppLogger.error('Payment processing error', e);
    if (mounted) {
      _showInvalidQRPopup();
    }
  } finally {
    if (mounted) {
      cameraController.start();
      setState(() => _isProcessing = false);
    }
  }
}

// Custom exception for insufficient balance
class InsufficientBalanceException implements Exception {
  final String message;
  final String studentName;
  final double currentBalance;

  InsufficientBalanceException(this.message, this.currentBalance)
      : studentName = 'Unknown';

  @override
  String toString() => message;
}

@override
void dispose() {
  cameraController.dispose();
  super.dispose();
}
```

---

### Step 2.4: Fix StudentMapScreen - Error Handling

```dart
@override
void initState() {
  super.initState();
  _initializeMap();
}

void _initializeMap() {
  _determinePosition().then((_) {
    _loadBusesForRoute();
  }).catchError((e) {
    AppLogger.warning('Location error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    // Still load buses with default location
    _loadBusesForRoute();
  });
}

Future<void> _determinePosition() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    final Position position = await Geolocator.getCurrentPosition(
      timeLimit: AppConstants.locationTimeout,
    );

    final GoogleMapController controller = await _controller.future;
    if (mounted) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: AppConstants.mapZoomStudent,
          ),
        ),
      );
    }
  } catch (e) {
    AppLogger.error('Error determining position', e);
    rethrow;
  }
}
```

---

## PART 3: UPDATE main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/session_manager.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NsbmShuttleApp());
}

class NsbmShuttleApp extends StatelessWidget {
  const NsbmShuttleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPointerDown: (_) {
        // Record user activity for session management
        SessionManager().recordActivity();
      },
      child: MaterialApp(
        title: 'NSBM Bus Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
```

---

## PART 4: Update pubspec.yaml

Add these dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.10.0
  cloud_firestore: ^4.13.0
  google_maps_flutter: ^2.5.0
  geolocator: ^10.0.0
  mobile_scanner: ^3.4.0
  qr_flutter: ^4.1.0
  flutter_cupertino_localizations: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

---

## QUICK REFERENCE: Implementation Checklist

- [ ] Create `lib/core/constants/app_colors.dart`
- [ ] Create `lib/core/constants/app_constants.dart`
- [ ] Create `lib/core/theme/app_theme.dart`
- [ ] Create `lib/core/utils/logger.dart`
- [ ] Create `lib/core/utils/validators.dart`
- [ ] Create `lib/core/utils/session_manager.dart`
- [ ] Create `lib/widgets/ios_text_field.dart`
- [ ] Update `lib/screens/login_screen.dart`
- [ ] Update `lib/screens/signup_screen.dart`
- [ ] Update `lib/screens/driver_scanner_screen.dart`
- [ ] Update `lib/screens/student_map_screen.dart`
- [ ] Update `lib/main.dart`
- [ ] Update `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Test all screens for functionality
- [ ] Test error scenarios

---

**Total Implementation Time:** 4-6 hours for experienced Flutter developer

