import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart'; // iOS style icons walata
import 'login_screen.dart'; 
import 'student_wallet_screen.dart'; 

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String firstName = "Loading...";
  String lastName = "";
  String studentId = "...";
  String username = "...";
  double walletBalance = 0.0;

  // Premium Colors (iOS Style)
  final Color iosBackground = const Color(0xFFF2F2F7);
  final Color darkBlue = const Color(0xFF0A1D37);
  final Color premiumGreen = const Color(0xFF00C7BE);
  final Color cardWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          firstName = userDoc['firstName'] ?? 'Student';
          lastName = userDoc['lastName'] ?? '';
          studentId = userDoc['studentId'] ?? 'N/A';
          username = userDoc['username'] ?? '';
          walletBalance = (userDoc['walletBalance'] ?? 0.0).toDouble();
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen()), 
        (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: iosBackground,
      
      // --- APP BAR (Clean iOS Style) ---
      appBar: AppBar(
        backgroundColor: iosBackground,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: TextStyle(color: darkBlue, fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: darkBlue), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- PROFILE HEADER (Centered Avatar) ---
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]
                      ),
                      child: CircleAvatar(
                        radius: 55, 
                        backgroundColor: premiumGreen.withValues(alpha: 0.1), 
                        child: Icon(CupertinoIcons.person_solid, size: 55, color: premiumGreen)
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '$firstName $lastName', 
                      style: TextStyle(color: darkBlue, fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NSBM Green University', 
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // --- WALLET BALANCE CARD (Clickable iOS Group) ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const StudentWalletScreen())
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardWhite, 
                    borderRadius: BorderRadius.circular(20), 
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: premiumGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
                            child: Icon(CupertinoIcons.creditcard_fill, color: premiumGreen, size: 24),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Wallet Balance', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                'LKR ${walletBalance.toStringAsFixed(2)}', 
                                style: TextStyle(color: darkBlue, fontSize: 20, fontWeight: FontWeight.w800)
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(CupertinoIcons.chevron_right, color: Colors.grey.shade400, size: 20), 
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- USER DETAILS LIST (iOS Settings Style) ---
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 8),
                  child: Text('ACCOUNT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 1)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardWhite, 
                  borderRadius: BorderRadius.circular(20), 
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: Column(
                  children: [
                    _buildIosDetailRow(CupertinoIcons.doc_person_fill, 'Student ID', studentId),
                    Divider(height: 1, color: Colors.grey.shade200, indent: 50),
                    _buildIosDetailRow(CupertinoIcons.at, 'Username', '@$username'),
                    Divider(height: 1, color: Colors.grey.shade200, indent: 50),
                    _buildIosDetailRow(CupertinoIcons.mail_solid, 'Email', '$username@nsbm.lk'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- LOGOUT BUTTON (Apple Minimal Style) ---
              SizedBox(
                width: double.infinity, 
                height: 55,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    shadowColor: Colors.black.withValues(alpha: 0.05),
                    elevation: 2,
                  ),
                  onPressed: _logout,
                  child: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Settings wage lassanata list eka hadana function eka
  Widget _buildIosDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 22),
          const SizedBox(width: 15),
          Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: darkBlue)),
        ],
      ),
    );
  }
}
