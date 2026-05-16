import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'student_wallet_screen.dart';
import 'student_map_screen.dart';
import 'student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  // Variables for Swap Logic
  String _fromLocation = 'NSBM Green University';
  String _selectedRoute = 'Makumbura (MMC)';
  String _firstName = "Loading...";

  final Color darkBlue = const Color(0xFF0A1D37);
  final Color premiumGreen = const Color(0xFF00C7BE);
  final Color iosBg = const Color(0xFFF2F2F7);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

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
    }
  }

  // --- SWAP LOGIC ---
  void _swapLocations() {
    setState(() {
      String temp = _fromLocation;
      _fromLocation = _selectedRoute;
      _selectedRoute = temp;
    });
  }

  // --- MODERN BOTTOM SHEET PICKER ---
  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Select Destination",
              style: TextStyle(
                color: darkBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),

            _locationOption("Makumbura (MMC)", CupertinoIcons.map_pin_ellipse),
            _locationOption("Colombo Fort", CupertinoIcons.building_2_fill),
            _locationOption("NSBM Green University", CupertinoIcons.house_fill),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _locationOption(String title, IconData icon) {
    bool isSelected = _selectedRoute == title;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedRoute = title);
        Navigator.pop(context); // Menu à¶‘à¶š à·€à·„à¶±à·€à·
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? premiumGreen.withValues(alpha: 0.1)
              : iosBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? premiumGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? premiumGreen : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : darkBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: darkBlue,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                color: premiumGreen,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: iosBg,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: premiumGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _firstName,
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentProfileScreen(),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(
                              CupertinoIcons.person_crop_circle_fill,
                              color: darkBlue,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // --- ROUTE CARD WITH SWAP & CUSTOM PICKER ---
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
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
                            _buildRouteRow(
                              CupertinoIcons.location_north_fill,
                              "From",
                              _fromLocation,
                              premiumGreen,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: Colors.grey.shade100,
                                indent: 45,
                              ),
                            ),
                            // Modern "To" Selector
                            GestureDetector(
                              onTap: _showLocationPicker,
                              child: _buildRouteRow(
                                CupertinoIcons.bus,
                                "To",
                                _selectedRoute,
                                darkBlue,
                                isPicker: true,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Swap Button
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          onTap: _swapLocations,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              CupertinoIcons.arrow_up_arrow_down,
                              color: premiumGreen,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoPill(CupertinoIcons.calendar, "Date", "Today"),
                      const SizedBox(width: 12),
                      _buildInfoPill(
                        CupertinoIcons.person_2_fill,
                        "Seats",
                        "1 Seat",
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // --- FIND BUSES BUTTON ---
                  GestureDetector(
                    onTap: () {
                      // à¶¸à·™à¶­à¶±à·’à¶±à·Š à¶­à¶¸à¶ºà·’ Map à¶‘à¶šà¶§ à¶­à·à¶»à¶´à·” Location à¶§à·’à¶š à¶ºà·€à¶±à·Šà¶±à·š
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentMapScreen(
                            fromLocation: _fromLocation,
                            toLocation: _selectedRoute,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [premiumGreen, const Color(0xFF00B2A9)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: premiumGreen.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Find Available Buses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: premiumGreen,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            // à¶ºà¶§ Nav bar à¶‘à¶šà·™à¶±à·Š à¶œà·’à¶ºà¶­à·Š Location à¶ºà·€à¶±à·€à·
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentMapScreen(
                  fromLocation: _fromLocation,
                  toLocation: _selectedRoute,
                ),
              ),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentWalletScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.ticket),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.creditcard),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isPicker = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (isPicker)
          Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: Colors.grey.shade400,
          ),
      ],
    );
  }

  Widget _buildInfoPill(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

