# NSBM Shuttle - Comprehensive Bug Analysis & Optimization Report

**Analysis Date:** May 16, 2026  
**Analyzed Screens:** 11  
**Total Critical Issues Found:** 24  
**Total Optimization Opportunities:** 18

---

## EXECUTIVE SUMMARY

The NSBM Shuttle app has **good UI/UX design** but suffers from **critical resource management issues**, **missing error handling**, and **optimization problems** that could lead to crashes and poor performance. Below is the detailed breakdown with specific fixes.

---

## 🔴 CRITICAL SEVERITY ISSUES

### Issue #1: TextEditingController Memory Leak - LoginScreen
**File:** [lib/screens/login_screen.dart](lib/screens/login_screen.dart#L1)  
**Lines:** 19-20  
**Risk:** Memory leak on app lifecycle; controllers never disposed

```dart
// ❌ CURRENT CODE - MEMORY LEAK
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // No dispose() method!
}

// ✅ FIX - Add dispose method
@override
void dispose() {
  _usernameController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

**Impact:** Every time user opens login screen, controllers accumulate in memory. After multiple sessions, this causes memory leaks leading to app slowdown or crashes.

---

### Issue #2: TextEditingController Memory Leak - SignupScreen
**File:** [lib/screens/signup_screen.dart](lib/screens/signup_screen.dart#L1)  
**Lines:** 19-24  
**Risk:** Memory leak; 6 controllers never disposed

```dart
// ❌ CURRENT CODE - MEMORY LEAK
class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  // No dispose()!
}

// ✅ FIX - Add dispose method
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
```

**Impact:** Critical - signup screen visited multiple times (failed attempts) will cause severe memory leaks.

---

### Issue #3: MobileScannerController Not Disposed - DriverScannerScreen
**File:** [lib/screens/driver_scanner_screen.dart](lib/screens/driver_scanner_screen.dart#L14)  
**Lines:** 14  
**Risk:** Camera resource not released; battery drain, permission issues

```dart
// ❌ CURRENT CODE - RESOURCE LEAK
class _DriverScannerScreenState extends State<DriverScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  // No dispose!
}

// ✅ FIX - Add dispose method
@override
void dispose() {
  cameraController.dispose();
  super.dispose();
}
```

**Impact:** Camera remains active even after navigating away. This drains battery, prevents other apps from using camera, and could cause app crashes.

---

### Issue #4: Race Condition in Payment Processing - DriverScannerScreen
**File:** [lib/screens/driver_scanner_screen.dart](lib/screens/driver_scanner_screen.dart#L23-60)  
**Lines:** 23-60  
**Risk:** Double charge - same student can be charged twice

```dart
// ❌ CURRENT CODE - RACE CONDITION
Future<void> _processPayment(String studentId) async {
  if (_isProcessing) return;
  
  setState(() => _isProcessing = true);
  cameraController.stop(); // Scanner stops but delay before data save
  
  try {
    // Two separate Firestore operations - can fail between them!
    DocumentSnapshot studentDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(studentId)
        .get();
    
    // Network can fail here! Balance deducted but payment record lost
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(studentId)
        .update({'walletBalance': currentBalance - ticketPrice});
  } catch (e) {
    // Generic error handling
    cameraController.start();
    setState(() => _isProcessing = false);
  }
}

// ✅ FIX - Use Firestore transactions
Future<void> _processPayment(String studentId) async {
  if (_isProcessing) return;
  
  setState(() => _isProcessing = true);
  cameraController.stop();
  
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final ticketPrice = 120.0;
    
    // Use transaction to ensure atomicity
    await firestore.runTransaction((transaction) async {
      final snapshot = transaction.get(
        firestore.collection('Users').doc(studentId)
      );
      
      if (!snapshot.exists || snapshot['role'] != 'student') {
        throw Exception('Invalid student');
      }
      
      double currentBalance = (snapshot['walletBalance'] ?? 0.0).toDouble();
      
      if (currentBalance < ticketPrice) {
        throw Exception('Insufficient balance');
      }
      
      // Create payment record BEFORE deducting balance
      final paymentRef = firestore.collection('Payments').doc();
      transaction.set(paymentRef, {
        'studentId': studentId,
        'studentName': snapshot['username'],
        'amount': ticketPrice,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
      
      // Deduct balance in same transaction
      transaction.update(
        firestore.collection('Users').doc(studentId),
        {'walletBalance': currentBalance - ticketPrice}
      );
      
      if (mounted) {
        _showIosPopup(true, snapshot['username'], currentBalance - ticketPrice);
      }
    });
  } catch (e) {
    if (mounted) {
      String errorMsg = 'Error: $e';
      _showError(errorMsg);
    }
  } finally {
    if (mounted) {
      cameraController.start();
      setState(() => _isProcessing = false);
    }
  }
}

void _showError(String message) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Payment Error'),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          child: const Text('Try Again'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
```

**Impact:** Students could be charged twice; payment integrity compromised.

---

### Issue #5: Null Reference Exception Risk - StudentMapScreen
**File:** [lib/screens/student_map_screen.dart](lib/screens/student_map_screen.dart#L1)  
**Lines:** 1-50  
**Risk:** Future exception not handled

```dart
// ❌ CURRENT CODE - NO ERROR HANDLING
@override
void initState() {
  super.initState();
  _determinePosition();  // Can throw exception!
  _loadBusesForRoute();
}

Future<void> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return Future.error('Location services are disabled.');
  // This error is thrown but never caught!
}

// ✅ FIX - Handle futures properly
@override
void initState() {
  super.initState();
  _initializeScreen();
}

void _initializeScreen() {
  _determinePosition().then((_) {
    _loadBusesForRoute();
  }).catchError((e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    final GoogleMapController controller = await _controller.future;
    if (mounted) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.0,
          ),
        ),
      );
    }
  } catch (e) {
    print('Error determining position: $e');
  }
}
```

**Impact:** App crashes if location services denied or GPS unavailable.

---

### Issue #6: Unvalidated Firebase Document Access - DriverScannerScreen
**File:** [lib/screens/driver_scanner_screen.dart](lib/screens/driver_scanner_screen.dart#L32-40)  
**Lines:** 32-40  
**Risk:** Crash if 'role' or 'username' fields missing

```dart
// ❌ CURRENT CODE - NO NULL CHECKS
if (studentDoc.exists && studentDoc['role'] == 'student') {
  String studentName = studentDoc['username'];  // Can be null!
  double currentBalance = (studentDoc['walletBalance'] ?? 0.0).toDouble();
  // ...
}

// ✅ FIX - Add proper null checking
if (studentDoc.exists) {
  final data = studentDoc.data() as Map<String, dynamic>?;
  if (data == null) {
    throw Exception('Invalid student data');
  }
  
  final role = data['role'] as String?;
  if (role != 'student') {
    throw Exception('Not a valid student');
  }
  
  final studentName = data['username'] as String? ?? 'Unknown Student';
  final currentBalance = (data['walletBalance'] as num? ?? 0.0).toDouble();
  
  const ticketPrice = 120.0;
  if (currentBalance >= ticketPrice) {
    // Safe to proceed
  }
} else {
  throw Exception('Student not found');
}
```

**Impact:** App crashes when scanning QR of students with incomplete data.

---

### Issue #7: No Input Validation - LoginScreen & SignupScreen
**File:** [lib/screens/login_screen.dart](lib/screens/login_screen.dart#L38), [lib/screens/signup_screen.dart](lib/screens/signup_screen.dart#L38)  
**Lines:** Login: 38-42, Signup: 38-42  
**Risk:** Empty field submission; weak password accepted

```dart
// ❌ CURRENT CODE - MINIMAL VALIDATION
if (inputUsername.isEmpty || inputPassword.isEmpty) {
  throw Exception("Please enter both Username and Password.");
}

// ✅ FIX - Comprehensive validation
bool _validateLoginInput(String username, String password) {
  // Check length
  if (username.length < 3) {
    throw Exception('Username must be at least 3 characters');
  }
  if (username.length > 20) {
    throw Exception('Username must not exceed 20 characters');
  }
  if (password.length < 6) {
    throw Exception('Password must be at least 6 characters');
  }
  
  // Check special characters in username
  if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
    throw Exception('Username can only contain letters, numbers, - and _');
  }
  
  return true;
}

bool _validateSignupInput(String firstName, String lastName, String username, 
    String email, String password, String id) {
  // Name validation
  if (firstName.trim().isEmpty || firstName.length < 2) {
    throw Exception('First name must be at least 2 characters');
  }
  if (lastName.trim().isEmpty || lastName.length < 2) {
    throw Exception('Last name must be at least 2 characters');
  }
  
  // Username validation
  if (username.length < 3 || username.length > 20) {
    throw Exception('Username must be 3-20 characters');
  }
  
  // Email validation
  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
      .hasMatch(email)) {
    throw Exception('Please enter a valid email address');
  }
  
  // Password validation
  if (password.length < 8) {
    throw Exception('Password must be at least 8 characters');
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    throw Exception('Password must contain an uppercase letter');
  }
  if (!RegExp(r'[0-9]').hasMatch(password)) {
    throw Exception('Password must contain a number');
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
    throw Exception('Password must contain a special character');
  }
  
  // ID validation (Student ID or NIC)
  if (id.trim().isEmpty || id.length < 3) {
    throw Exception('Please enter a valid ID');
  }
  
  return true;
}
```

**Impact:** Invalid data entered into system; database integrity compromised.

---

### Issue #8: Unhandled Firebase Auth Exceptions - LoginScreen
**File:** [lib/screens/login_screen.dart](lib/screens/login_screen.dart#L64-80)  
**Lines:** 64-80  
**Risk:** Generic error messages; user confusion

```dart
// ❌ CURRENT CODE - GENERIC ERROR HANDLING
catch (e) {
  if (mounted) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Login Failed'),
        content: Text(e.toString().replaceAll('Exception: ', '')),
        // ...
      ),
    );
  }
}

// ✅ FIX - Specific error handling
catch (e) {
  String errorMessage = _getLoginErrorMessage(e);
  if (mounted) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Login Failed'),
        content: Text(errorMessage),
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

String _getLoginErrorMessage(dynamic e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'Username not found. Please check or sign up for a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'invalid-email':
        return 'Invalid email format. Please try again.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Login is currently disabled. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Login failed. Please try again.';
    }
  } else if (e is Exception) {
    final message = e.toString().replaceAll('Exception: ', '');
    return message;
  }
  return 'An unexpected error occurred.';
}
```

**Impact:** Users don't understand why login failed; poor UX.

---

### Issue #9: Missing null check in StudentHomeScreen
**File:** [lib/screens/student_home_screen.dart](lib/screens/student_home_screen.dart#L38)  
**Lines:** 38-49  
**Risk:** Crash if user fetch fails

```dart
// ❌ CURRENT CODE - NO ERROR HANDLING
Future<void> _fetchUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    if (userDoc.exists && mounted) {
      setState(() {
        _firstName = userDoc['firstName'] ?? 'Student';
      });
    }
    // What if document doesn't exist? Silent failure!
  }
}

// ✅ FIX - Add error handling
Future<void> _fetchUserData() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists && mounted) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _firstName = data['firstName'] as String? ?? 'Student';
          });
        }
      } else if (mounted) {
        // User data doesn't exist - should not happen normally
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
      }
    }
  } catch (e) {
    print('Error fetching user data: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }
}
```

**Impact:** Silent failures; user sees "Loading..." forever.

---

## 🟠 HIGH SEVERITY ISSUES

### Issue #10: No Error Handling in Signup Payment Creation
**File:** [lib/screens/signup_screen.dart](lib/screens/signup_screen.dart#L48-65)  
**Lines:** 48-65  
**Risk:** Silent failure if Firebase write fails

```dart
// ❌ CURRENT CODE
try {
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
  );

  Map<String, dynamic> userData = { /* ... */ };
  
  // Can fail but no error recovery
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userCredential.user!.uid)
      .set(userData);

  if (mounted) {
    if (_selectedRole == 'driver') {
      Navigator.pushReplacement(/* ... */);
    } else {
      Navigator.pushReplacement(/* ... */);
    }
  }
} catch (e) {
  _showError(e.toString().replaceAll('Exception: ', ''));
}

// ✅ FIX - Add specific error handling
try {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  
  // Check if user already exists
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // If successful, user exists
    throw Exception('This email is already registered. Please login instead.');
  } catch (e) {
    if (e is FirebaseAuthException && e.code != 'user-not-found') {
      rethrow;
    }
    // User doesn't exist, continue with signup
  }
  
  UserCredential userCredential = 
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  if (userCredential.user == null) {
    throw Exception('Signup failed. Please try again.');
  }

  Map<String, dynamic> userData = {
    'firstName': _firstNameController.text.trim(),
    'lastName': _lastNameController.text.trim(),
    'username': _usernameController.text.trim(),
    'email': email,
    'role': _selectedRole, 
    'walletBalance': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
    'status': 'active',
  };

  if (_selectedRole == 'student') {
    userData['studentId'] = _idController.text.trim();
  } else {
    userData['nicNumber'] = _idController.text.trim();
  }

  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userCredential.user!.uid)
      .set(userData);

  // If we reach here, both auth and database operations succeeded
  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => _selectedRole == 'driver' 
            ? const DriverHomeScreen() 
            : const StudentHomeScreen(),
      ),
      (route) => false,
    );
  }
} on FirebaseAuthException catch (e) {
  String message = _getSignupAuthError(e);
  _showError(message);
  // Attempt to delete the auth account if Firestore write failed
  try {
    await FirebaseAuth.instance.currentUser?.delete();
  } catch (_) {
    // Already logged in user, no need to delete
  }
} catch (e) {
  _showError('Signup failed: ${e.toString()}');
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

**Impact:** Users create auth accounts but fail to create profiles; data inconsistency.

---

### Issue #11: Hardcoded Colors throughout App
**File:** Multiple - [login_screen.dart](lib/screens/login_screen.dart), [signup_screen.dart](lib/screens/signup_screen.dart), all screens  
**Risk:** Hard to maintain; inconsistency; theming impossible

```dart
// ❌ CURRENT CODE - Colors hardcoded everywhere
final Color darkBlue = const Color(0xFF0A1D37);
final Color premiumGreen = const Color(0xFF00C7BE);

// Then repeated in every screen...

// ✅ FIX - Create a theme constants file
// lib/core/constants/app_colors.dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00754A);
  static const Color primaryDark = Color(0xFF0A1D37);
  static const Color primaryLight = Color(0xFF00C7BE);
  
  // Secondary Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);
  
  // Background & Text
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0A1D37);
  static const Color textSecondary = Color(0xFF757575);
  
  // Neutral
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
}

// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

// Usage in main.dart
MaterialApp(
  title: 'NSBM Bus Tracker',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  home: const SplashScreen(),
)
```

**Impact:** Hard to rebrand or update colors; inconsistent UI.

---

### Issue #12: No Constants File for Hardcoded Values
**File:** Multiple - [driver_scanner_screen.dart](lib/screens/driver_scanner_screen.dart#L42)  
**Risk:** Hardcoded ticket price; hard to update

```dart
// ❌ CURRENT CODE
double ticketPrice = 120.0;  // Hardcoded in multiple places

// ✅ FIX - Create constants file
// lib/core/constants/app_constants.dart
class AppConstants {
  // Pricing
  static const double ticketPrice = 120.0;
  static const double minWalletBalance = 10.0;
  static const double maxWalletBalance = 10000.0;
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 15);
  
  // Location coordinates
  static const double nsbmLatitude = 6.8213;
  static const double nsbmLongitude = 80.0416;
  static const double mapZoom = 14.4746;
  
  // Validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 8;
  
  // Collections
  static const String usersCollection = 'Users';
  static const String paymentsCollection = 'Payments';
  static const String bussesCollection = 'Busses';
  static const String tripsCollection = 'Trips';
}

// Usage
const ticketPrice = AppConstants.ticketPrice;
```

**Impact:** Hard to maintain pricing, limits, and configs.

---

### Issue #13: No Null Safety in DriverHomeScreen
**File:** [lib/screens/driver_home_screen.dart](lib/screens/driver_home_screen.dart#L65)  
**Lines:** 65  
**Risk:** Crash if update fails

```dart
// ❌ CURRENT CODE - Force unwrap
await FirebaseFirestore.instance
    .collection('Users')
    .doc(user.uid)
    .update({
      'isTripActive': isTripActive,
      'latitude': 6.8211,
      'longitude': 80.0399,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

// ✅ FIX - Proper error handling
try {
  if (user == null) {
    throw Exception('User not authenticated');
  }
  
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(user.uid)
      .update({
        'isTripActive': isTripActive,
        'latitude': 6.8211,
        'longitude': 80.0399,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating trip status: $e')),
    );
  }
  // Revert UI state
  setState(() {
    isTripActive = !isTripActive;
  });
}
```

**Impact:** App crashes if network error during trip toggle.

---

### Issue #14: No Logging or Error Tracking
**File:** All files  
**Risk:** Impossible to debug production issues

```dart
// ✅ FIX - Add proper logging
// lib/core/utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSingleLine,
    ),
  );
  
  static void logDebug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }
  
  static void logInfo(String message) {
    _logger.i(message);
  }
  
  static void logWarning(String message, [dynamic error]) {
    _logger.w(message, error: error);
  }
  
  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

// Usage throughout app
try {
  await someFutureOperation();
} catch (e, stackTrace) {
  AppLogger.logError('Operation failed', e, stackTrace);
}
```

**Impact:** Can't diagnose production bugs; poor support experience.

---

## 🟡 MEDIUM SEVERITY ISSUES

### Issue #15: Duplicate TextField Widget Builder
**File:** [login_screen.dart](lib/screens/login_screen.dart#L263), [signup_screen.dart](lib/screens/signup_screen.dart#L250)  
**Risk:** Code duplication; maintenance nightmare

```dart
// ❌ CURRENT CODE - Same widget defined in both files
Widget _buildIosTextField({
  required TextEditingController controller,
  required IconData icon,
  required String hint,
  bool isPassword = false,
}) {
  // Implementation repeated...
}

// ✅ FIX - Create reusable widget
// lib/widgets/ios_text_field.dart
class IosTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData? icon;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  
  const IosTextField({
    Key? key,
    required this.controller,
    this.icon,
    required this.hint,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<IosTextField> createState() => _IosTextFieldState();
}

class _IosTextFieldState extends State<IosTextField> {
  late FocusNode _focusNode;
  
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _focusNode.hasFocus 
              ? AppColors.primaryLight 
              : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: Colors.grey.shade500, size: 20)
              : null,
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 18,
            horizontal: widget.icon == null ? 20 : 0,
          ),
          suffixIcon: widget.isPassword 
              ? IconButton(
                  icon: Icon(
                    _focusNode.hasFocus 
                        ? CupertinoIcons.eye_solid 
                        : CupertinoIcons.eye_slash,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () {
                    // Toggle password visibility
                  },
                )
              : null,
        ),
        validator: widget.validator,
      ),
    );
  }
}

// Usage
IosTextField(
  controller: _usernameController,
  icon: CupertinoIcons.person_solid,
  hint: 'Username',
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Username is required';
    }
    return null;
  },
)
```

**Impact:** Bug fixes need to be applied in multiple places.

---

### Issue #16: Missing Input Sanitization
**File:** [signup_screen.dart](lib/screens/signup_screen.dart#L62)  
**Risk:** Injection attacks; data corruption

```dart
// ❌ CURRENT CODE - Raw input
userData['firstName'] = _firstNameController.text.trim();

// ✅ FIX - Sanitize input
String _sanitizeInput(String input) {
  // Remove HTML/script tags
  final sanitized = input
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll(RegExp(r'[;\"\'\\]'), '')
      .trim();
  
  // Remove multiple spaces
  return sanitized.replaceAll(RegExp(r'\s+'), ' ');
}

userData['firstName'] = _sanitizeInput(_firstNameController.text);
userData['lastName'] = _sanitizeInput(_lastNameController.text);
userData['username'] = _sanitizeInput(_usernameController.text);
```

**Impact:** XSS vulnerability; database contains malicious data.

---

### Issue #17: No Pagination in Transaction History - StudentWalletScreen
**File:** [lib/screens/student_wallet_screen.dart](lib/screens/student_wallet_screen.dart#L150-200)  
**Risk:** Performance issue with many transactions

```dart
// ❌ CURRENT CODE - Hardcoded 3 transactions
Column(
  children: [
    _buildIosTransaction('NSBM Bus - Makumbura', 'Today, 07:30 AM', 
        '- LKR 120.00', Colors.redAccent, CupertinoIcons.bus),
    Divider(...),
    _buildIosTransaction('Wallet Top Up', 'Yesterday, 14:20 PM', 
        '+ LKR 500.00', premiumGreen, CupertinoIcons.add_circled_solid),
    // ...
  ],
)

// ✅ FIX - Fetch from Firestore with pagination
class _StudentWalletScreenState extends State<StudentWalletScreen> {
  late final FirebaseFirestore _firestore;
  late Query _transactionsQuery;
  late PaginatedDataTable _dataSource;
  static const int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _transactionsQuery = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Transactions')
          .orderBy('timestamp', descending: true);
      _fetchTransactions();
    }
  }

  Future<void> _fetchTransactions() async {
    // Implement pagination
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _transactionsQuery.limit(pageSize).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const CupertinoActivityIndicator();
        }

        final transactions = snapshot.data!.docs;
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index].data() as Map<String, dynamic>;
            return _buildTransactionTile(tx);
          },
        );
      },
    );
  }
}
```

**Impact:** Loads all transactions at once; memory issue with many transactions.

---

### Issue #18: No Loading State for Async Operations
**File:** Multiple  
**Risk:** User doesn't know if operation is running

```dart
// ❌ CURRENT CODE - No loading state
void _login() async {
  setState(() {
    _isLoading = true;
  });
  try {
    // Operation
  }
  setState(() {
    _isLoading = false;
  });
}

// ✅ FIX - Better loading state management
Future<void> _fetchUserData() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });
  try {
    // Actual operation
  } on FirebaseException catch (e) {
    setState(() {
      _error = _getErrorMessage(e);
    });
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// In build method
if (_isLoading) {
  return const Center(
    child: CupertinoActivityIndicator(),
  );
}

if (_error != null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.exclamationmark_circle,
          color: Colors.red,
          size: 60,
        ),
        const SizedBox(height: 16),
        Text(_error!),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _fetchUserData,
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

**Impact:** Users get confused; appears frozen.

---

## 🟢 LOW SEVERITY ISSUES / OPTIMIZATIONS

### Issue #19: Hardcoded Route Coordinates in StudentMapScreen
**File:** [lib/screens/student_map_screen.dart](lib/screens/student_map_screen.dart#L20-30)  
**Optimization:** Use route/location database

```dart
// ❌ CURRENT CODE - Dummy data
if (widget.toLocation == 'Makumbura (MMC)') {
  setState(() {
    _busMarkers.add(
      Marker(
        markerId: const MarkerId('bus_1'),
        position: const LatLng(6.8250, 80.0400),
        // ...
      ),
    );
  });
}

// ✅ FIX - Fetch from database
Future<void> _loadBusesForRoute() async {
  try {
    final QuerySnapshot busSnapshot = await FirebaseFirestore.instance
        .collection('Busses')
        .where('route', isEqualTo: widget.toLocation)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .first;

    final Set<Marker> markers = {};
    for (var doc in busSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(
            (data['latitude'] as num).toDouble(),
            (data['longitude'] as num).toDouble(),
          ),
          infoWindow: InfoWindow(
            title: data['busNumber'] as String? ?? 'Bus',
            snippet: 'Route: ${data['route']}',
          ),
        ),
      );
    }
    
    if (mounted) {
      setState(() {
        _busMarkers = markers;
      });
    }
  } catch (e) {
    AppLogger.logError('Failed to load buses', e);
  }
}
```

---

### Issue #20: Repeated Color Initialization
**File:** All screen files  
**Optimization:** Use Theme.of(context)

```dart
// ❌ CURRENT CODE - Repeated in every class
final Color darkBlue = const Color(0xFF0A1D37);
final Color premiumGreen = const Color(0xFF00C7BE);

// ✅ FIX - Use extension method
extension ColorExtension on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get accentColor => Theme.of(this).colorScheme.secondary;
}

// Usage
Text(
  'Welcome',
  style: TextStyle(color: context.primaryColor),
)
```

---

### Issue #21: No Retry Logic for Failed Network Requests
**File:** Multiple  
**Optimization:** Add exponential backoff

```dart
// ✅ FIX - Implement retry logic
Future<T> _retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
}) async {
  int retryCount = 0;
  
  while (true) {
    try {
      return await operation();
    } catch (e) {
      if (retryCount >= maxRetries) {
        rethrow;
      }
      
      final delay = Duration(milliseconds: 100 * (retryCount + 1));
      await Future.delayed(delay);
      retryCount++;
    }
  }
}

// Usage
await _retryWithBackoff(() => 
  FirebaseFirestore.instance
    .collection('Users')
    .doc(userId)
    .get()
);
```

---

### Issue #22: No Debouncing for Repeated Button Taps
**File:** Multiple button handlers  
**Optimization:** Prevent double submissions

```dart
// ✅ FIX - Create debounce utility
class DebouncedAction {
  VoidCallback? _timedAction;
  final Duration duration;

  DebouncedAction({this.duration = const Duration(seconds: 1)});

  void run(VoidCallback action) {
    _timedAction?.call();
    _timedAction = action;

    Future.delayed(duration, () {
      _timedAction?.call();
      _timedAction = null;
    });
  }

  void dispose() {
    _timedAction = null;
  }
}

// Usage in Widget
class _MyScreenState extends State<MyScreen> {
  late DebouncedAction _debouncedLogin;

  @override
  void initState() {
    super.initState();
    _debouncedLogin = DebouncedAction();
  }

  void _login() {
    _debouncedLogin.run(() {
      // Actual login logic
    });
  }

  @override
  void dispose() {
    _debouncedLogin.dispose();
    super.dispose();
  }
}
```

---

### Issue #23: No Certificate Pinning for API Security
**File:** main.dart  
**Optimization:** Secure HTTP connections

```dart
// ✅ FIX - Add certificate pinning
// pubspec.yaml
dependencies:
  firebase_core: ^2.0.0
  cloud_firestore: ^4.0.0
  dio: ^5.0.0
  http_certificate_pinning: ^2.0.0

// lib/core/network/http_client.dart
import 'package:dio/dio.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio();
    _setupPinning();
  }

  Future<void> _setupPinning() async {
    try {
      // Use your Firebase certificate hash
      final certificateHashes = [
        'sha256/iKPIHPnDvq55iB1X5Jn3yPA2yN06cHRx8Ed+O7MmwJ8=',
      ];

      await HttpCertificatePinning.check(
        serverURL: 'https://firestore.googleapis.com',
        headerServerKeyPinning: certificateHashes,
        allowedSslErrors: [],
        timeout: 60,
      );
    } catch (e) {
      AppLogger.logError('Certificate pinning failed', e);
    }
  }
}
```

---

### Issue #24: No Session Management
**File:** All screens  
**Optimization:** Implement session timeout

```dart
// ✅ FIX - Add session management
// lib/core/utils/session_manager.dart
class SessionManager {
  static const sessionTimeout = Duration(minutes: 15);
  static DateTime? _lastActivity;
  
  static void recordActivity() {
    _lastActivity = DateTime.now();
  }
  
  static bool isSessionExpired() {
    if (_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) > sessionTimeout;
  }
  
  static void clearSession() {
    _lastActivity = null;
  }
}

// In main.dart
void main() {
  runApp(
    MaterialApp(
      home: GestureDetector(
        onPointerDown: (_) => SessionManager.recordActivity(),
        child: const MyApp(),
      ),
    ),
  );
}
```

---

## IMPLEMENTATION PRIORITY ROADMAP

### Phase 1 - Critical Fixes (Week 1)
1. ✅ Fix TextEditingController dispose() - LoginScreen & SignupScreen
2. ✅ Fix MobileScannerController dispose() - DriverScannerScreen  
3. ✅ Add payment transaction atomicity - DriverScannerScreen
4. ✅ Add input validation - LoginScreen & SignupScreen
5. ✅ Fix error handling for futures - StudentMapScreen

### Phase 2 - High Priority Fixes (Week 2)
6. ✅ Create constants file (AppConstants)
7. ✅ Create theme file (AppTheme)
8. ✅ Add Firebase error handling - all screens
9. ✅ Create reusable IosTextField widget
10. ✅ Add logger utility

### Phase 3 - Medium Optimizations (Week 3)
11. ✅ Input sanitization
12. ✅ Pagination for transactions
13. ✅ Better loading states
14. ✅ Remove duplicate code

### Phase 4 - Final Optimizations (Week 4)
15. ✅ Add retry logic
16. ✅ Add debouncing
17. ✅ Session management
18. ✅ Certificate pinning

---

## RECOMMENDED PACKAGE UPDATES

Add these to `pubspec.yaml`:

```yaml
dependencies:
  logger: ^1.4.0  # For logging
  dio: ^5.0.0  # Better HTTP client
  connectivity_plus: ^5.0.0  # Network detection
  internet_connection_checker: ^1.0.0  # Connection check
  fpdart: ^0.5.0  # Functional programming
  riverpod: ^2.0.0  # State management
  freezed_annotation: ^2.0.0  # Data class generation
  json_serializable: ^6.0.0  # JSON serialization
  get_it: ^7.0.0  # Dependency injection
  
dev_dependencies:
  build_runner: ^2.0.0
  freezed: ^2.0.0
  json_serializable: ^6.0.0
```

---

## FILE MODIFICATION CHECKLIST

- [ ] `lib/main.dart` - Update theme
- [ ] `lib/screens/login_screen.dart` - Add dispose(), validation, error handling
- [ ] `lib/screens/signup_screen.dart` - Add dispose(), validation, sanitization, error handling
- [ ] `lib/screens/driver_scanner_screen.dart` - Fix transaction, add dispose()
- [ ] `lib/screens/student_map_screen.dart` - Add error handling for futures
- [ ] `lib/screens/driver_home_screen.dart` - Add error handling
- [ ] `lib/screens/student_home_screen.dart` - Add error handling
- [ ] `lib/screens/student_profile_screen.dart` - Add dispose() if controllers exist
- [ ] `lib/screens/student_wallet_screen.dart` - Add pagination, dispose()
- [ ] Create `lib/core/constants/app_colors.dart`
- [ ] Create `lib/core/constants/app_constants.dart`
- [ ] Create `lib/core/theme/app_theme.dart`
- [ ] Create `lib/core/utils/logger.dart`
- [ ] Create `lib/core/utils/validators.dart`
- [ ] Create `lib/widgets/ios_text_field.dart`
- [ ] Create `lib/core/utils/session_manager.dart`

---

## TESTING RECOMMENDATIONS

```dart
// Test cases to add:
// 1. Test TextEditingController disposal
// 2. Test payment transaction atomicity
// 3. Test input validation
// 4. Test error scenarios (no internet, Firebase errors)
// 5. Test concurrent operations
// 6. Test session timeout
// 7. Test memory leaks with ProfilerTest
```

---

## CONCLUSION

The NSBM Shuttle app has solid UI design but needs **urgent fixes** in resource management, error handling, and security. Implementing Phase 1 fixes will eliminate most crashes. Phases 2-4 will improve maintainability and performance.

**Estimated Fix Time:** 3-4 weeks with one developer

