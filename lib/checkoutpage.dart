import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad_ca3/home.dart';
import 'package:mad_ca3/ordersuccesspage.dart';
import 'package:mad_ca3/card_details_page.dart'; // Add this import

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(List<Map<String, dynamic>>) onCartChanged;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.onCartChanged,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late List<Map<String, dynamic>> _cart;
  Map<String, String>? _savedCardDetails;
  bool _hasCardDetails = false;

  @override
  void initState() {
    super.initState();
    _cart = List<Map<String, dynamic>>.from(widget.cartItems);
    _loadSavedCardDetails();
  }

  Future<void> _loadSavedCardDetails() async {
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
          _savedCardDetails = {
            'cardNumber': data['cardNumber'] ?? '',
            'nameOnCard': data['nameOnCard'] ?? '',
            'expiryDate': data['expiryDate'] ?? '',
            'cvv': data['cvv'] ?? '',
            'address': data['address'] ?? '',
          };
          _hasCardDetails = true;
        });
      }
    } catch (e) {
      print('Error loading saved card details: $e');
    }
  }

  Future<void> _navigateToCardDetails() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailsPage(
          onCardSaved: (cardDetails) {
            setState(() {
              _savedCardDetails = cardDetails;
              _hasCardDetails = true;
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _savedCardDetails = Map<String, String>.from(result);
        _hasCardDetails = true;
      });
    }
  }

  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $lastFour';
  }

  void _removeItem(int index) {
    setState(() {
      _cart.removeAt(index);
    });
    widget.onCartChanged(_cart);
  }

  double get subtotal => _cart.fold(
    0,
    (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)),
  );

  double get taxes => subtotal * 0.09;

  double get shipping => _cart.isEmpty ? 0 : 1.99;

  double get total => subtotal + taxes + shipping;

  Future<void> _placeOrder() async {
    // Check if card details are available
    if (!_hasCardDetails) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please add payment details first'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final placedOrder = List<Map<String, dynamic>>.from(_cart);
    lastPlacedOrder = placedOrder;

    final firestore = FirebaseFirestore.instance;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange.shade600,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Processing payment...',
                style: TextStyle(fontSize: 16, color: Colors.brown.shade700),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // 1. Save placed order to Firestore under user's orders subcollection
      await firestore.collection('users').doc(uid).collection('orders').add({
        'items': placedOrder,
        'paymentDetails': {
          'cardNumber': _maskCardNumber(_savedCardDetails!['cardNumber']!),
          'nameOnCard': _savedCardDetails!['nameOnCard'],
          'address': _savedCardDetails!['address'],
        },
        'totalAmount': total,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Clear user's cart in Firestore
      await firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc('current')
          .delete();

      // 3. Update local cart and navigate
      setState(() {
        _cart.clear();
      });
      widget.onCartChanged(_cart);

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Payment processed successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessPage(orderedItems: placedOrder),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to process payment. Please try again.'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Checkout',
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
          child: _cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add some pet essentials to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
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
                                    Icons.pets,
                                    size: 24,
                                    color: Colors.orange.shade700,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Review Your Order',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // Payment Details Section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.payment,
                                        color: Colors.orange.shade700,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Payment Method',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  if (_hasCardDetails &&
                                      _savedCardDetails != null) ...[
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.credit_card,
                                            color: Colors.green.shade600,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _maskCardNumber(
                                                    _savedCardDetails!['cardNumber']!,
                                                  ),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.green.shade800,
                                                  ),
                                                ),
                                                Text(
                                                  _savedCardDetails!['nameOnCard']!,
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: _navigateToCardDetails,
                                            child: Text(
                                              'Change',
                                              style: TextStyle(
                                                color: Colors.orange.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange.shade200,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.credit_card_outlined,
                                            color: Colors.orange.shade600,
                                            size: 32,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'No payment method added',
                                            style: TextStyle(
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Add a payment method to continue',
                                            style: TextStyle(
                                              color: Colors.orange.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: _navigateToCardDetails,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.orange.shade600,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: Icon(Icons.add, size: 16),
                                            label: Text(
                                              'Add Payment Method',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // Cart Items List
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _cart.length,
                              itemBuilder: (context, index) {
                                final item = _cart[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(
                                                  0.1,
                                                ),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.asset(
                                              item['img'],
                                              width: 240,
                                              height: 240,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.brown.shade700,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                item['desc'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'SGD \$${(item['price'] * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        Colors.orange.shade800,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .remove_circle_outline,
                                                            size: 20,
                                                            color: Colors
                                                                .orange
                                                                .shade600,
                                                          ),
                                                          onPressed: () {
                                                            if (item['quantity'] >
                                                                1) {
                                                              setState(() {
                                                                item['quantity']--;
                                                              });
                                                              widget
                                                                  .onCartChanged(
                                                                    _cart,
                                                                  );
                                                            } else {
                                                              _removeItem(
                                                                index,
                                                              );
                                                            }
                                                          },
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                              ),
                                                          child: Text(
                                                            '${item['quantity'] ?? 1}',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .brown
                                                                  .shade700,
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .add_circle_outline,
                                                            size: 20,
                                                            color: Colors
                                                                .orange
                                                                .shade600,
                                                          ),
                                                          onPressed: () {
                                                            if ((item['quantity'] ??
                                                                    1) <
                                                                item['stock']) {
                                                              setState(() {
                                                                item['quantity']++;
                                                              });
                                                              widget
                                                                  .onCartChanged(
                                                                    _cart,
                                                                  );
                                                            } else {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .pets,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        'Reached max stock limit!',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .orange
                                                                          .shade600,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  IconButton(
                                                    icon: Container(
                                                      padding: EdgeInsets.all(
                                                        6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade50,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.delete_outline,
                                                        color:
                                                            Colors.red.shade600,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                              'Confirm Removal',
                                                            ),
                                                            content: Text(
                                                              'Are you sure you want to remove this item from cart?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                  'No',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(), // close dialog
                                                              ),
                                                              TextButton(
                                                                child: Text(
                                                                  'Yes, Remove',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(); // close dialog
                                                                  _removeItem(
                                                                    index,
                                                                  ); // actually remove item
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: Colors.orange.shade700,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Order Summary',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildSummaryRow('Subtotal', subtotal),
                                  _buildSummaryRow('Shipping', shipping),
                                  _buildSummaryRow('Taxes (9% GST)', taxes),
                                  Divider(
                                    thickness: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.brown.shade700,
                                        ),
                                      ),
                                      Text(
                                        'SGD \$${total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _placeOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasCardDetails
                                      ? Colors.orange.shade600
                                      : Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                ),
                                icon: Icon(
                                  _hasCardDetails
                                      ? Icons.shopping_bag_outlined
                                      : Icons.lock_outlined,
                                ),
                                label: Text(
                                  _hasCardDetails
                                      ? 'Place Order'
                                      : 'Add Payment Method First',
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
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          Text(
            'SGD \$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
