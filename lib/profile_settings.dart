import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController petNameController = TextEditingController();
  TextEditingController followersController = TextEditingController();
  TextEditingController followingController = TextEditingController();
  TextEditingController vaccinationsController = TextEditingController();
  TextEditingController healthController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  File? _imageFile;
  Uint8List? _base64ImageBytes;
  List<Map<String, dynamic>> vaccinationRecords = [];
  bool _isUploading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _loadProfile();
    _loadVaccinationRecords();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 129, 210, 230).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo,
                  color: Color.fromARGB(255, 129, 210, 230),
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Change Profile Picture",
                style: TextStyle(
                  color: Color(0xFF2D4A3E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to update your profile picture?",
            style: TextStyle(color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 129, 210, 230),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _base64ImageBytes = imageBytes;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImageBase64', base64Image);

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'profileImageBase64': base64Image,
              }, SetOptions(merge: true));
        }

        _showSuccessSnackBar("Profile picture updated successfully!");
      }
    }
  }

  // Replace your existing _uploadVaccinationRecord method with this:
  Future<void> _uploadVaccinationRecord() async {
    try {
      // Show options for camera or gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.add_a_photo,
                color: Color.fromARGB(255, 129, 210, 230),
              ),
              SizedBox(width: 8),
              Text(
                "Add Vaccination Record",
                style: TextStyle(
                  color: Color(0xFF2D4A3E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            "Choose how you want to add your vaccination record:",
            style: TextStyle(color: Colors.grey[600]),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text("Camera"),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text("Gallery"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
          ],
        ),
      );

      if (source != null) {
        setState(() {
          _isUploading = true;
        });

        final pickedFile = await ImagePicker().pickImage(
          source: source,
          maxWidth: 1500,
          maxHeight: 1500,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            // Read image bytes
            final imageBytes = await pickedFile.readAsBytes();
            final base64Image = base64Encode(imageBytes);

            // Get file info
            final fileName = pickedFile.name;
            final fileSize = imageBytes.length;

            // Create vaccination record entry
            final recordData = {
              'fileName': fileName,
              'uploadDate': DateTime.now().toIso8601String(),
              'fileSize': fileSize,
              'fileExtension': fileName.split('.').last.toLowerCase(),
              'timestamp': FieldValue.serverTimestamp(),
              'fileData': base64Image,
              'isImage': true,
              'uploadSource': source == ImageSource.camera
                  ? 'camera'
                  : 'gallery',
            };

            // Add to Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('vaccinationRecords')
                .add(recordData);

            // Update vaccination count
            final currentCount = int.tryParse(vaccinationsController.text) ?? 0;
            final newCount = currentCount + 1;
            vaccinationsController.text = newCount.toString();

            // Update user document
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'vaccinations': newCount.toString()});

            await _loadVaccinationRecords();
            _showSuccessSnackBar(
              "Vaccination record uploaded successfully! Vaccination count updated.",
            );
          }
        }
      }
    } catch (e) {
      print('Upload error: $e');
      _showErrorSnackBar(
        "Failed to upload vaccination record: ${e.toString()}",
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _loadVaccinationRecords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('vaccinationRecords')
            .orderBy('uploadDate', descending: true)
            .get();

        setState(() {
          vaccinationRecords = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
      } catch (e) {
        print('Error loading vaccination records: $e');
      }
    }
  }

  Future<void> _deleteVaccinationRecord(String recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Record"),
        content: Text(
          "Are you sure you want to delete this vaccination record?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('vaccinationRecords')
              .doc(recordId)
              .delete();

          // Update vaccination count
          final currentCount = int.tryParse(vaccinationsController.text) ?? 0;
          if (currentCount > 0) {
            final newCount = currentCount - 1;
            vaccinationsController.text = newCount.toString();

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'vaccinations': newCount.toString()});
          }

          await _loadVaccinationRecords();
          _showSuccessSnackBar("Vaccination record deleted successfully!");
        }
      } catch (e) {
        _showErrorSnackBar("Failed to delete record: ${e.toString()}");
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 129, 210, 230),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        nameController.text = data['name'] ?? '';
        petNameController.text = data['petName'] ?? '';
        followersController.text = data['followers'] ?? '';
        followingController.text = data['following'] ?? '';
        vaccinationsController.text = data['vaccinations'] ?? '0';
        healthController.text = data['health'] ?? '5';
        statusController.text = data['status'] ?? '';

        final base64Image =
            data['profileImageBase64'] ?? prefs.getString('profileImageBase64');
        if (base64Image != null) {
          final imageBytes = base64Decode(base64Image);
          setState(() {
            _base64ImageBytes = imageBytes;
          });
        }

        // Save to SharedPreferences
        await prefs.setString('name', nameController.text);
        await prefs.setString('petName', petNameController.text);
        await prefs.setString('followers', followersController.text);
        await prefs.setString('following', followingController.text);
        await prefs.setString('vaccinations', vaccinationsController.text);
        await prefs.setString('health', healthController.text);
        await prefs.setString('status', statusController.text);
        if (base64Image != null) {
          await prefs.setString('profileImageBase64', base64Image);
        }
      } else {
        // Fallback to SharedPreferences
        nameController.text = prefs.getString('name') ?? '';
        petNameController.text = prefs.getString('petName') ?? '';
        followersController.text = prefs.getString('followers') ?? '';
        followingController.text = prefs.getString('following') ?? '';
        vaccinationsController.text = prefs.getString('vaccinations') ?? '0';
        healthController.text = prefs.getString('health') ?? '5';
        statusController.text = prefs.getString('status') ?? '';

        final base64Image = prefs.getString('profileImageBase64');
        if (base64Image != null) {
          final imageBytes = base64Decode(base64Image);
          setState(() {
            _base64ImageBytes = imageBytes;
          });
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('petName', petNameController.text);
    await prefs.setString('followers', followersController.text);
    await prefs.setString('following', followingController.text);
    await prefs.setString('vaccinations', vaccinationsController.text);
    await prefs.setString('health', healthController.text);
    await prefs.setString('status', statusController.text);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameController.text,
        'petName': petNameController.text,
        'followers': followersController.text,
        'following': followingController.text,
        'vaccinations': vaccinationsController.text,
        'health': healthController.text,
        'status': statusController.text,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _showSuccessSnackBar("Profile saved successfully!");
    Navigator.pop(context);
  }

  void _confirmSaveProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.save, color: Color.fromARGB(255, 129, 210, 230)),
            SizedBox(width: 8),
            Text(
              "Confirm Changes",
              style: TextStyle(
                color: Color(0xFF2D4A3E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to save these changes to your profile?",
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 129, 210, 230),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Yes, Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: 16, color: Color(0xFF2D4A3E)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 129, 210, 230).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color.fromARGB(255, 129, 210, 230),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 129, 210, 230),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildVaccinationRecordCard(Map<String, dynamic> record) {
    final fileName = record['fileName'] ?? 'Vaccination Record';
    final uploadDate = record['uploadDate'] != null
        ? DateTime.parse(record['uploadDate'])
        : DateTime.now();
    final uploadSource = record['uploadSource'] ?? 'gallery';
    final fileSize = record['fileSize'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.fromARGB(255, 129, 210, 230).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail preview
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color.fromARGB(255, 129, 210, 230).withOpacity(0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: record['fileData'] != null
                  ? Image.memory(
                      base64Decode(record['fileData']),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Color.fromARGB(
                          255,
                          129,
                          210,
                          230,
                        ).withOpacity(0.1),
                        child: Icon(
                          Icons.image,
                          color: Color.fromARGB(255, 129, 210, 230),
                        ),
                      ),
                    )
                  : Container(
                      color: Color.fromARGB(
                        255,
                        129,
                        210,
                        230,
                      ).withOpacity(0.1),
                      child: Icon(
                        Icons.image,
                        color: Color.fromARGB(255, 129, 210, 230),
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D4A3E),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      uploadSource == 'camera'
                          ? Icons.camera_alt
                          : Icons.photo_library,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Uploaded: ${uploadDate.day}/${uploadDate.month}/${uploadDate.year}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                if (fileSize > 0)
                  Text(
                    'Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
              ],
            ),
          ),
          // View button
          IconButton(
            icon: Icon(
              Icons.visibility,
              color: Color.fromARGB(255, 129, 210, 230),
            ),
            onPressed: () => _viewVaccinationRecord(record),
          ),
          // Delete button
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
            onPressed: () => _deleteVaccinationRecord(record['id']),
          ),
        ],
      ),
    );
  }

  // Add this method to view the full image
  void _viewVaccinationRecord(Map<String, dynamic> record) {
    if (record['fileData'] != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(record['fileData']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 129, 210, 230).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF2D4A3E),
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4A3E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture Section
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
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
                                          child: ClipOval(
                                            child: _base64ImageBytes != null
                                                ? Image.memory(
                                                    _base64ImageBytes!,
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                  )
                                                : _imageFile != null
                                                ? Image.file(
                                                    _imageFile!,
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'assets/img/dog_avatar.png',
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              129,
                                              210,
                                              230,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                offset: Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Tap to change photo',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 32),

                          // Basic Info Section
                          Text(
                            '🐾 Basic Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D4A3E),
                            ),
                          ),
                          SizedBox(height: 16),

                          _buildTextField(
                            controller: nameController,
                            label: 'Your Name',
                            icon: Icons.person,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: petNameController,
                            label: 'Pet Name',
                            icon: Icons.pets,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your pet\'s name';
                              }
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: healthController,
                            label: 'Health Score (1-10)',
                            icon: Icons.favorite,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final num = int.tryParse(value ?? '');
                              if (num == null || num < 1 || num > 10) {
                                return 'Please enter a number between 1 and 10';
                              }
                              return null;
                            },
                          ),

                          _buildTextField(
                            controller: statusController,
                            label: 'Status Message',
                            icon: Icons.message,
                            maxLines: 2,
                          ),

                          SizedBox(height: 32),

                          // Vaccination Section
                          Row(
                            children: [
                              Text(
                                '💉 Vaccination Records',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D4A3E),
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(
                                    255,
                                    129,
                                    210,
                                    230,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color.fromARGB(
                                      255,
                                      129,
                                      210,
                                      230,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Total: ${vaccinationsController.text}',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 129, 210, 230),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          _buildTextField(
                            controller: vaccinationsController,
                            label: 'Manual Vaccination Count',
                            icon: Icons.medical_services,
                            keyboardType: TextInputType.number,
                          ),

                          // Upload Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isUploading
                                  ? null
                                  : _uploadVaccinationRecord,
                              icon: _isUploading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.upload_file,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                _isUploading
                                    ? 'Uploading...'
                                    : 'Upload Vaccination Record',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  163,
                                  181,
                                  209,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Vaccination Records List
                          if (vaccinationRecords.isNotEmpty) ...[
                            Text(
                              'Uploaded Records:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D4A3E),
                              ),
                            ),
                            SizedBox(height: 12),
                            ...vaccinationRecords.map(
                              (record) => _buildVaccinationRecordCard(record),
                            ),
                          ],

                          SizedBox(height: 32),

                          // Save Button
                          Container(
                            width: double.infinity,
                            height: 56,
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
                                  color: Color.fromARGB(
                                    255,
                                    129,
                                    210,
                                    230,
                                  ).withOpacity(0.4),
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _confirmSaveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Save Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 40),
                        ],
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
}
