import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mad_ca3/appointment_confirmation_page.dart';
import 'package:mad_ca3/dog_run.dart';
import 'package:mad_ca3/login.dart';
import 'package:mad_ca3/ordersuccesspage.dart';
import 'package:mad_ca3/pet_friendly_malls.dart';
import 'package:mad_ca3/profile_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'groom_page.dart';
import 'shop_page.dart';
import 'vet_page.dart';
import 'check_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

List<Map<String, dynamic>> lastPlacedOrder = [];

AppointmentData? lastBookedAppointment;

class AppointmentData {
  final TimeOfDay? vetTime;
  final TimeOfDay? groomTime;
  final String? vetName;
  final String? groomName;

  AppointmentData({this.vetTime, this.groomTime, this.vetName, this.groomName});
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomePageContent(onOrderUpdated: _refresh),
      GroomPage(),
      ShopPage(),
      VetPage(),
      CheckPage(),
    ];
    _loadLastAppointmentFromFirebase();
  }

  Future<void> _loadLastAppointmentFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('appointments')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        print("Appointment docs found: ${snapshot.docs.length}");

        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          print("Latest appointment data: $data");

          final vetName = data['vetName'] as String?;
          final groomName = data['groomName'] as String?;
          final vetTimeStr = data['vetTime'] as String?;
          final groomTimeStr = data['groomTime'] as String?;

          print("Vet: $vetName at $vetTimeStr");
          print("Groom: $groomName at $groomTimeStr");

          TimeOfDay? parseTimeString(String? timeStr) {
            if (timeStr == null || timeStr.isEmpty) return null;
            try {
              final parts = timeStr.split(':');
              if (parts.length == 2) {
                final hour = int.tryParse(parts[0]);
                final minute = int.tryParse(parts[1]);
                if (hour != null && minute != null) {
                  return TimeOfDay(hour: hour, minute: minute);
                }
              }
            } catch (e) {
              print("Error parsing time string '$timeStr': $e");
            }
            return null;
          }

          final vetTime = parseTimeString(vetTimeStr);
          final groomTime = parseTimeString(groomTimeStr);

          setState(() {
            lastBookedAppointment = AppointmentData(
              vetTime: vetTime,
              groomTime: groomTime,
              vetName: vetName,
              groomName: groomName,
            );
          });

          print(
            "Set appointment: vet=${vetTime != null ? '${vetTime.hour}:${vetTime.minute}' : 'null'}, groom=${groomTime != null ? '${groomTime.hour}:${groomTime.minute}' : 'null'}",
          );
        } else {
          print("No appointments found");
          setState(() {
            lastBookedAppointment = null;
          });
        }
      } catch (e) {
        print('Error loading appointment: $e');
        setState(() {
          lastBookedAppointment = null;
        });
      }
    } else {
      print("No user logged in");
      setState(() {
        lastBookedAppointment = null;
      });
    }
  }

  Future<bool> _hasAnyAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('appointments')
            .limit(1)
            .get();
        return snapshot.docs.isNotEmpty;
      } catch (e) {
        print('Error checking appointments: $e');
        return false;
      }
    }
    return false;
  }

  void _refresh() {
    setState(() {});
  }

  final List<String> _titles = [
    'Home',
    'Groom',
    'Shop',
    'Vet',
    'Dog Food Safety Checker',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    lastPlacedOrder.clear();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 129, 210, 230),
                Color.fromARGB(255, 163, 181, 209),
                Color(0xFFA8C5C1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 129, 210, 230),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'PAWPAL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D4A3E),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Appointments button
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Tooltip(
                                message: "View Appointments",
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.event_note,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AppointmentConfirmationPage(),
                                      ),
                                    );
                                    await _loadLastAppointmentFromFirebase();
                                  },
                                ),
                              ),
                            ),
                            FutureBuilder<bool>(
                              future: _hasAnyAppointments(),
                              builder: (context, snapshot) {
                                if (snapshot.data == true) {
                                  return Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ],
                        ),

                        SizedBox(width: 8),

                        // Orders button
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Tooltip(
                                message: "View Order",
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (lastPlacedOrder.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("No recent orders yet"),
                                          backgroundColor: Color(0xFFE6A981),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderSuccessPage(
                                                orderedItems: lastPlacedOrder,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (lastPlacedOrder.isNotEmpty)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(width: 8),

                        // Menu button
                        PopupMenuButton<String>(
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          offset: Offset(-10, 50),
                          onSelected: (value) {
                            if (value == 'logout') {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Text('Confirm Logout'),
                                  content: Text(
                                    'Are you sure you want to log out?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromARGB(
                                          255,
                                          129,
                                          210,
                                          230,
                                        ),
                                      ),
                                      child: Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text('Logout'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8), // Right padding
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Color.fromARGB(255, 129, 210, 230),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.content_cut),
              label: 'Groom',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital),
              label: 'Vet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sentiment_satisfied),
              label: 'Check',
            ),
          ],
        ),
      ),
    );
  }
}

String? profilePicPath;
String? profileImageBase64;
String? profileImageUrl;

class HomePageContent extends StatefulWidget {
  static bool cartItemAdded = false;
  final Function onOrderUpdated;
  const HomePageContent({required this.onOrderUpdated, Key? key})
    : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String petName = 'User';
  String vaccinations = '0', health = '0';
  int uploadedRecordsCount = 0;
  List<Map<String, dynamic>> recentVaccinationRecords = [];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _promoImages = [
    'assets/img/promo_banner.png',
    'assets/img/promo_banner_2.png',
    'assets/img/promo_banner_3.png',
    'assets/img/promo_banner_4.png',
    'assets/img/promo_banner_5.png',
  ];

  final List<Map<String, String>> _articles = [
    {
      'title': 'Puppy Proof Your House',
      'description': 'How to keep your puppy safe at home.',
      'url':
          'https://www.petmd.com/dog/general-health/how-to-puppy-proof-your-house',
    },
    {
      'title': 'Understand Dog Body Language',
      'description': 'Learn how to read your dog\'s signals.',
      'url': 'https://www.petmd.com/dog/behavior/how-to-read-dog-body-language',
    },
    {
      'title': 'Dog Vaccinations Guide',
      'description': 'Vaccination needs for every stage of life.',
      'url':
          'https://www.petmd.com/dog/care/dog-vaccinations-for-every-lifestage',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _initProfile();
    lastPlacedOrder.clear();
    _loadLastOrderFromFirebase();
  }

  void _launchURL(String url) async {
    print('Trying to launch: $url');
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      print('Can launch! Launching...');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Cannot launch url');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open the link')));
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _promoImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  void _loadLastOrderFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          lastPlacedOrder = List<Map<String, dynamic>>.from(data['items']);
        });
        widget.onOrderUpdated();
      }
    }
  }

  // Load vaccination records from Firebase
  Future<void> _loadVaccinationRecords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('vaccinationRecords')
            .orderBy('uploadDate', descending: true)
            .limit(3) // Get only the 3 most recent records for home display
            .get();

        setState(() {
          recentVaccinationRecords = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          uploadedRecordsCount = snapshot.docs.length;
        });

        // Get total count of all vaccination records
        final totalSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('vaccinationRecords')
            .get();

        setState(() {
          uploadedRecordsCount = totalSnapshot.docs.length;
        });
      } catch (e) {
        print('Error loading vaccination records: $e');
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initProfile() async {
    await clearPrefsIfNewUser();
    await _loadProfile();
    await loadUserData();
    await _loadVaccinationRecords();
  }

  String status = '';
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        profileImageUrl = doc.data()?['profileImageUrl'];
      });
    }
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    status = prefs.getString('status') ?? '';

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        petName = data['petName'] ?? 'User';
        vaccinations = data['vaccinations'] ?? '0';
        health = data['health'] ?? '0';
        status = data['status'] ?? '';

        profileImageBase64 =
            data['profileImageBase64'] ?? prefs.getString('profileImageBase64');

        await prefs.setString('petName', petName);
        await prefs.setString('vaccinations', vaccinations);
        await prefs.setString('health', health);
        await prefs.setString('status', status);
        if (profileImageBase64 != null) {
          await prefs.setString('profileImageBase64', profileImageBase64!);
        }
      } else {
        petName = prefs.getString('petName') ?? 'User';
        vaccinations = prefs.getString('vaccinations') ?? '0';
        health = prefs.getString('health') ?? '0';
        status = prefs.getString('status') ?? '';
        profileImageBase64 = prefs.getString('profileImageBase64');
      }
    }

    setState(() {});
  }

  Future<void> clearPrefsIfNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final lastUid = prefs.getString('lastUser');

    if (uid != null && uid != lastUid) {
      await prefs.clear();
      await prefs.setString('lastUser', uid);
    }
  }

  String _getVaccinationStatus() {
    final totalVaccinations = int.tryParse(vaccinations) ?? 0;
    if (totalVaccinations >= 5) {
      return 'Fully Protected';
    } else if (totalVaccinations >= 3) {
      return 'Well Protected';
    } else if (totalVaccinations >= 1) {
      return 'Partially Protected';
    } else {
      return 'Needs Vaccination';
    }
  }

  Color _getVaccinationStatusColor() {
    final totalVaccinations = int.tryParse(vaccinations) ?? 0;
    if (totalVaccinations >= 5) {
      return Colors.green;
    } else if (totalVaccinations >= 3) {
      return Color.fromARGB(255, 129, 210, 230);
    } else if (totalVaccinations >= 1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Profile Section
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 129, 210, 230).withOpacity(0.1),
                  Color(0xFFA8C5C1).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileSettingsPage()),
                  ).then((_) async {
                    await _loadProfile();
                    await _loadVaccinationRecords();
                  }),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(
                            255,
                            129,
                            210,
                            230,
                          ).withOpacity(0.3),
                          offset: Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundImage: profileImageBase64 != null
                          ? MemoryImage(base64Decode(profileImageBase64!))
                          : AssetImage('assets/img/dog_avatar.png')
                                as ImageProvider,
                      radius: 50,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          petName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4A3E),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatChip(
                              '💉 $vaccinations',
                              _getVaccinationStatusColor(),
                            ),
                            SizedBox(width: 8),
                            _buildStatChip('❤️ $health/10', Colors.red),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Vaccination Status
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getVaccinationStatusColor().withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getVaccinationStatusColor().withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            _getVaccinationStatus(),
                            style: TextStyle(
                              color: _getVaccinationStatusColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (status.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFA8C5C1).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '"$status"',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF2D4A3E),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Vaccination Records Summary (if any exist)
          if (recentVaccinationRecords.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: Color.fromARGB(255, 129, 210, 230),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Recent Vaccination Records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D4A3E),
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(
                            255,
                            129,
                            210,
                            230,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$uploadedRecordsCount files',
                          style: TextStyle(
                            color: Color.fromARGB(255, 129, 210, 230),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...recentVaccinationRecords.take(2).map((record) {
                    final fileName = record['fileName'] ?? 'Unknown file';
                    final uploadDate = record['uploadDate'] != null
                        ? DateTime.parse(record['uploadDate'])
                        : DateTime.now();
                    final isImage = record['isImage'] == true;

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          129,
                          210,
                          230,
                        ).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color.fromARGB(
                            255,
                            129,
                            210,
                            230,
                          ).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isImage ? Icons.image : Icons.picture_as_pdf,
                            color: Color.fromARGB(255, 129, 210, 230),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2D4A3E),
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${uploadDate.day}/${uploadDate.month}/${uploadDate.year}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (uploadedRecordsCount > 2)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${uploadedRecordsCount - 2} more records',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Enhanced Edit Profile Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 129, 210, 230),
                  Color.fromARGB(255, 163, 181, 209),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 129, 210, 230).withOpacity(0.3),
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileSettingsPage()),
                ).then((_) async {
                  await _loadProfile();
                  await _loadVaccinationRecords();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Edit Profile & Manage Vaccinations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 32),

          // Enhanced Promotions Section
          _buildSectionHeader('🎉 Promotions', 'Special offers just for you!'),
          SizedBox(height: 16),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 300, // cap height so desktop isn't huge
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9, // standard widescreen banner
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // PageView for promo banners
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _promoImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ShopPage()),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              _promoImages[index],
                              fit: BoxFit
                                  .contain, // show whole image without cropping
                              width: double.infinity,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Left button
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),

                  // Right button
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32),

          // Enhanced Leisures Section
          _buildSectionHeader(
            '🏃‍♂️ Activities',
            'Fun places to visit with your pet',
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  'Dog Runs',
                  '🐶',
                  'Find nearby dog parks',
                  Color.fromARGB(255, 129, 210, 230),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DogRunsMapPage()),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActivityCard(
                  'Pet Malls',
                  '🛍️',
                  'Pet-friendly shopping',
                  Color(0xFFA8C5C1),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PetFriendlyMallsPage()),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 32),

          // Enhanced Tips Section
          _buildSectionHeader('💡 Tips & Tricks', 'Expert advice for pet care'),
          SizedBox(height: 16),

          ..._articles.map((article) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  article['title']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D4A3E),
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    article['description']!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                trailing: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 129, 210, 230).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.open_in_new,
                    color: Color.fromARGB(255, 129, 210, 230),
                    size: 20,
                  ),
                ),
                onTap: () => _launchURL(article['url']!),
              ),
            );
          }).toList(),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D4A3E),
          ),
        ),
        SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActivityCard(
    String title,
    String emoji,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji, style: TextStyle(fontSize: 24))),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D4A3E),
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
