import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/cupertino.dart'; // iOS Icons

class DriverScannerScreen extends StatefulWidget {
  const DriverScannerScreen({super.key});

  @override
  State<DriverScannerScreen> createState() => _DriverScannerScreenState();
}

class _DriverScannerScreenState extends State<DriverScannerScreen> {
  bool _isProcessing = false;
  late MobileScannerController cameraController;

  // Premium Colors (iOS Style)
  final Color darkBlue = const Color(0xFF0A1D37);
  final Color premiumGreen = const Color(0xFF00C7BE);

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(String studentId) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    cameraController.stop();

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      const double ticketPrice = 120.0;

      // Use transaction to ensure atomicity - prevents double charging
      await firestore.runTransaction<void>((transaction) async {
        final userRef = firestore.collection('Users').doc(studentId);
        final snapshot = await transaction.get(userRef);

        // Verify document exists and user is student
        if (!snapshot.exists) {
          throw Exception('Student not found');
        }

        final data = snapshot.data();
        if (data == null) {
          throw Exception('Invalid student data');
        }

        final role = data['role'] as String?;
        if (role != 'student') {
          throw Exception('Not a valid student');
        }

        final studentName = data['username'] as String? ?? 'Unknown';
        final currentBalance = (data['walletBalance'] as num? ?? 0.0)
            .toDouble();

        // Check balance
        if (currentBalance < ticketPrice) {
          if (mounted) {
            _showIosPopup(false, studentName, currentBalance);
          }
          throw Exception('Insufficient balance');
        }

        // Create payment record BEFORE deducting balance (audit trail)
        final paymentRef = firestore.collection('Payments').doc();
        transaction.set(paymentRef, {
          'studentId': studentId,
          'studentName': studentName,
          'amount': ticketPrice,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
        });

        // Deduct balance in same transaction (atomic operation)
        transaction.update(userRef, {
          'walletBalance': currentBalance - ticketPrice,
        });

        if (mounted) {
          _showIosPopup(true, studentName, currentBalance - ticketPrice);
        }
      });
    } catch (e) {
      // Only show error if not already shown by transaction
      if (mounted && !e.toString().contains('Insufficient balance')) {
        _showError(e.toString());
      }
      cameraController.start();
      setState(() => _isProcessing = false);
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
            onPressed: () {
              Navigator.pop(context);
              cameraController.start();
              setState(() => _isProcessing = false);
            },
          ),
        ],
      ),
    );
  }

  // --- APPLE STYLE BLURRED POPUP ---
  void _showIosPopup(bool isSuccess, String studentName, double balance) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor:
          Colors.transparent, // <-- ERROR EKA FIX KALA (backgroundColor nemei)
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.white.withValues(
            alpha: 0.95,
          ), // Warning eka fix kala
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? premiumGreen.withValues(alpha: 0.1)
                        : CupertinoColors.destructiveRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.exclamationmark_triangle_fill,
                    color: isSuccess
                        ? premiumGreen
                        : CupertinoColors.destructiveRed,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  isSuccess ? 'Payment Verified' : 'Insufficient Balance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  studentName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isSuccess ? 'New Balance' : 'Current Balance',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'LKR ${balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess
                          ? darkBlue
                          : CupertinoColors.destructiveRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      cameraController.start();
                      setState(() => _isProcessing = false);
                    },
                    child: Text(
                      isSuccess ? 'Next Passenger' : 'Close',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- FULL SCREEN CAMERA ---
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !_isProcessing) {
                  _processPayment(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // --- DARK OVERLAY WITH CLEAR CENTER ---
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- VIEW FINDER BORDERS (Apple Style Corners) ---
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: premiumGreen, width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // --- FLOATING BACK BUTTON ---
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- INSTRUCTION TEXT ---
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Align QR code within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- PROCESSING INDICATOR ---
          if (_isProcessing)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 20,
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
