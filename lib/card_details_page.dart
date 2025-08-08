import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardDetailsPage extends StatefulWidget {
  final Function(Map<String, String>)? onCardSaved;

  const CardDetailsPage({Key? key, this.onCardSaved}) : super(key: key);

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _saveCard = true;
  Map<String, String>? _existingCard;

  @override
  void initState() {
    super.initState();
    _loadExistingCardDetails();
  }

  Future<void> _loadExistingCardDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payment')
          .doc('card_details')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _existingCard = {
            'cardNumber': data['cardNumber'] ?? '',
            'nameOnCard': data['nameOnCard'] ?? '',
            'expiryDate': data['expiryDate'] ?? '',
            'cvv': data['cvv'] ?? '',
            'address': data['address'] ?? '',
          };

          // Pre-fill the form with existing data
          _cardNumberController.text = _existingCard!['cardNumber']!;
          _nameController.text = _existingCard!['nameOnCard']!;
          _expiryController.text = _existingCard!['expiryDate']!;
          _cvvController.text = _existingCard!['cvv']!;
          _addressController.text = _existingCard!['address']!;
        });
      }
    } catch (e) {
      print('Error loading card details: $e');
    }
  }

  Future<void> _saveCardDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final cardDetails = {
        'cardNumber': _cardNumberController.text.trim(),
        'nameOnCard': _nameController.text.trim(),
        'expiryDate': _expiryController.text.trim(),
        'cvv': _cvvController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_saveCard) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('payment')
            .doc('card_details')
            .set(cardDetails);
      }

      // Call the callback with card details
      if (widget.onCardSaved != null) {
        widget.onCardSaved!(
          cardDetails.map((key, value) => MapEntry(key, value.toString())),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Card details saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );

      Navigator.pop(context, cardDetails);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to save card details'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    // Remove spaces for validation
    final cleanValue = value.replaceAll(' ', '');
    if (cleanValue.length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!regex.hasMatch(value)) {
      return 'Enter valid expiry (MM/YY)';
    }

    // Additional validation to check if the date is not in the past
    final parts = value.split('/');
    if (parts.length == 2) {
      final month = int.tryParse(parts[0]);
      final year = int.tryParse('20${parts[1]}');
      if (month != null && year != null) {
        final now = DateTime.now();
        final expiryDate = DateTime(
          year,
          month + 1,
          0,
        ); // Last day of expiry month
        if (expiryDate.isBefore(now)) {
          return 'Card has expired';
        }
      }
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (value.length < 3 || value.length > 4) {
      return 'CVV must be 3-4 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.credit_card, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Payment Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade100,
                          Colors.yellow.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          size: 24,
                          color: Colors.orange.shade700,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your payment information is secure',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Card Number
                  _buildSectionHeader('Card Information'),
                  SizedBox(height: 12),
                  _buildInputField(
                    controller: _cardNumberController,
                    label: 'Card Number',
                    hint: '1234 5678 9012 3456',
                    icon: Icons.credit_card,
                    validator: _validateCardNumber,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _CardNumberFormatter(),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Name on Card
                  _buildInputField(
                    controller: _nameController,
                    label: 'Name on Card',
                    hint: 'John Doe',
                    icon: Icons.person,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Name is required' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 16),

                  // Expiry and CVV Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _expiryController,
                          label: 'Expiry Date',
                          hint: 'MM/YY',
                          icon: Icons.calendar_today,
                          validator: _validateExpiry,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _ExpiryDateFormatter(),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _cvvController,
                          label: 'CVV',
                          hint: '123',
                          icon: Icons.lock,
                          validator: _validateCVV,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Billing Address
                  _buildSectionHeader('Billing Address'),
                  SizedBox(height: 12),
                  _buildInputField(
                    controller: _addressController,
                    label: 'Address',
                    hint: '123 Main Street, City, Postal Code',
                    icon: Icons.location_on,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Address is required' : null,
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),

                  // Save Card Toggle
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.save, color: Colors.orange.shade600),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Save card details for future purchases',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ),
                        Switch(
                          value: _saveCard,
                          onChanged: (value) {
                            setState(() {
                              _saveCard = value;
                            });
                          },
                          activeColor: Colors.orange.shade600,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveCardDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      icon: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(Icons.save),
                      label: Text(
                        _isLoading ? 'Saving...' : 'Save Payment Details',
                        style: TextStyle(
                          fontSize: 18,
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.brown.shade700,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.orange.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

// Custom formatter for card number (adds spaces)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Fixed custom formatter for expiry date
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    // Don't allow more than 4 digits
    if (text.length > 4) {
      return oldValue;
    }

    String formattedText = '';

    if (text.length >= 1) {
      formattedText = text.substring(0, text.length >= 2 ? 2 : text.length);
    }

    if (text.length >= 3) {
      formattedText += '/' + text.substring(2, text.length);
    }

    // Calculate cursor position
    int selectionIndex = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
