import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart'; // iOS Icons
import 'package:qr_flutter/qr_flutter.dart';

class StudentWalletScreen extends StatefulWidget {
  const StudentWalletScreen({super.key});

  @override
  State<StudentWalletScreen> createState() => _StudentWalletScreenState();
}

class _StudentWalletScreenState extends State<StudentWalletScreen> {
  double walletBalance = 0.0;
  String studentId = "";

  // Premium Colors (iOS Style)
  final Color iosBackground = const Color(0xFFF2F2F7);
  final Color darkBlue = const Color(0xFF0A1D37);
  final Color premiumGreen = const Color(0xFF00C7BE);
  final Color cardWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && mounted) {
        setState(() {
          walletBalance = (userDoc['walletBalance'] ?? 0.0).toDouble();
          studentId = user.uid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: iosBackground, // iOS standard gray background
      // --- APP BAR (Clean iOS Style) ---
      appBar: AppBar(
        backgroundColor: iosBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Wallet',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // --- APPLE WALLET STYLE BALANCE CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF142850),
                      Color(0xFF0A1D37),
                    ], // Premium Dark Blue Gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: darkBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'NSBM Pay',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        Icon(
                          CupertinoIcons.creditcard_fill,
                          color: premiumGreen.withOpacity(0.8),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'LKR ${walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- QR CODE SCANNER SECTION (Minimal Box) ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(30),
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
                      Text(
                        'Show to Driver',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: iosBackground, width: 2),
                        ),
                        child: studentId.isNotEmpty
                            ? QrImageView(
                                data: studentId,
                                size: 160,
                                foregroundColor: darkBlue,
                              )
                            : const SizedBox(
                                height: 160,
                                width: 160,
                                child: Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        'SCAN TO PAY',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: premiumGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- TRANSACTION HISTORY (iOS List Style) ---
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  'RECENT TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 1,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildIosTransaction(
                      'NSBM Bus - Makumbura',
                      'Today, 07:30 AM',
                      '- LKR 120.00',
                      Colors.redAccent,
                      CupertinoIcons.bus,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200, indent: 65),
                    _buildIosTransaction(
                      'Wallet Top Up',
                      'Yesterday, 14:20 PM',
                      '+ LKR 500.00',
                      premiumGreen,
                      CupertinoIcons.add_circled_solid,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200, indent: 65),
                    _buildIosTransaction(
                      'NSBM Bus - Colombo',
                      '02 Apr, 16:15 PM',
                      '- LKR 120.00',
                      Colors.redAccent,
                      CupertinoIcons.bus,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // iOS Style Transaction List Item hadana function eka
  Widget _buildIosTransaction(
    String title,
    String date,
    String amount,
    Color amountColor,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: amountColor, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: amountColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
