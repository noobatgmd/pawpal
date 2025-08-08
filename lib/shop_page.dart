import 'package:flutter/material.dart';
import 'package:mad_ca3/checkoutpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopPage extends StatefulWidget {
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadCartFromFirestore();
  }

  Future<void> _loadCartFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc('current');

    final doc = await cartRef.get();
    if (doc.exists) {
      setState(() {
        cart = List<Map<String, dynamic>>.from(doc.data()?['items'] ?? []);
      });
    }
  }

  List<Map<String, dynamic>> cart = [];

  final List<Map<String, dynamic>> dogProducts = [
    {
      'img': 'assets/img/pedigree.png',
      'name': 'Pedigree Dog Food (Grilled Steak and Vegetable Flavour)',
      'price': 42,
      'desc': 'Complete nutrition with roasted chicken. Great for adult dogs.',
      'stock': 12,
      'rating': 4.7,
    },
    {
      'img': 'assets/img/wanpydogchew.png',
      'name': 'Wanpy Oven-Roasted Chicken Jerky & Calcium Bone Twists',
      'price': 3.90,
      'desc': 'Patented Dog Treats 100% Natural - Healthy Training Reward',
      'stock': 20,
      'rating': 4.5,
    },
    {
      'img': 'assets/img/cesarfood.png',
      'name': 'Cesar - Beef & Liver Pate Dog Food 100g',
      'price': 2,
      'desc':
          'Classic recipes made with carefully sourced ingredients of tender meat, all captured in a succulent chunk of a rich, tasty gravy that your dog will simply begging for more.',
      'stock': 40,
      'rating': 4.2,
    },
    {
      'img': 'assets/img/petcubes.png',
      'name': 'Pet Cubes - Salmon & Whitefish (Case) 28 Cubes',
      'price': 40,
      'desc': 'Gently Cooked - Salmon & Whitefish.',
      'stock': 10,
      'rating': 5,
    },
    {
      'img': 'assets/img/chickenbonebroth.png',
      'name': 'Pet Cubes-Chicken Bone Broth',
      'price': 8.5,
      'desc':
          'Chicken Bone Broth is high in collagen, glucosamine, chondroitin, gelatin and glycine. It releases nutrients and minerals that serve as an ideal supplement to your dog\'s regular diet.',
      'stock': 53,
      'rating': 4.7,
    },
    {
      'img': 'assets/img/dogtoy.png',
      'name': 'IKEA GOSIG GOLDEN',
      'price': 19.90,
      'desc': 'Soft toy, dog/golden retriever, 70 cm',
      'stock': 21,
      'rating': 4.1,
    },
    {
      'img': 'assets/img/dogcage.png',
      'name': 'Stefanplast Gulliver 2 (Dark/Light Grey)',
      'price': 44.70,
      'desc': 'Carrier for small sized pets with plastic door.',
      'stock': 7,
      'rating': 3.8,
    },
    {
      'img': 'assets/img/weepads.png',
      'name': 'Trustie Charcoal Wee Pads',
      'price': 34.60,
      'desc':
          'Be well equipped for long trips and puppy training with the Trustie Charcoal Ultra-Absorbant Wee Pad!',
      'stock': 9,
      'rating': 4.7,
    },
    {
      'img': 'assets/img/dentalchew.png',
      'name':
          'Absolute Holistic Value Pack Dental Chews for Dogs - Fresh Mint (160g)',
      'price': 6.90,
      'desc':
          'Absolute holistic dental chew are uniquely shaped to act like a toothbrush to effectively scrape plaque and tartar. They are designed with 360° nubs and ridges with hollow spaces between for better grip to clean teeth right down to the gum line while satisfying the canine instinct to chew.',
      'stock': 23,
      'rating': 4.5,
    },
  ];

  final List<Map<String, dynamic>> catProducts = [
    {
      'img': 'assets/img/kittenwetfood.png',
      'name': 'Royal Canin Kitten Wet Food in Sauce for Kittens',
      'price': 2.70,
      'desc':
          'It provides essential nutrients to promote optimal growth and development for your kitten even during the most sensitive stages.',
      'stock': 103,
      'rating': 4,
    },
    {
      'img': 'assets/img/lilykitchencatfood.png',
      'name': 'LILY\'S KITCHEN WET FOOD FOR CATS - Lamb Paté 85g',
      'price': 4,
      'desc':
          'A soft, smooth texture that makes them extra-lickable, they\'re packed full of proper meat and fish that cats can\'t help but devour.',
      'stock': 12,
      'rating': 4.7,
    },
    {
      'img': 'assets/img/catindoorfood.png',
      'name': 'ROYAL CANIN CAT INDOOR',
      'price': 3.8,
      'desc':
          'Indoor adult cats like yours tend to get less exercise than outdoor cats, that\'s why a balanced and complete diet containing beneficial nutrients is important for optimal health. ROYAL CANIN FHN Cat Indoor contains a highly digestible protein (L.I.P.) that\'s specifically selected for its very high digestibility.',
      'stock': 32,
      'rating': 3.9,
    },
    {
      'img': 'assets/img/cattreat.png',
      'name': 'RIVERD REPUBLIC Neco Stick PureValue5 (Chicken Fillet) 12gx4',
      'price': 4.60,
      'desc':
          'Neco Stick All Natural Pure Value 5 is a delightful treats your cats will surely love. Sharing some facts about Riverd Republic; most ingredients used for all kinds of treats is sourced in Tottori Japan, even the water!',
      'stock': 67,
      'rating': 4.9,
    },
    {
      'img': 'assets/img/cattreehouse.png',
      'name':
          'Cat Tree House Wood Cat Bed Scratcher House Tower Hammock Climbing',
      'price': 63.60,
      'desc':
          'Fluffy Nest Condo (Silver Grey/Beige/Dark brown colors), Dimension: 150cm x 40cm x 60cm, Weight: 14kg (Approx)',
      'stock': 9,
      'rating': 4.2,
    },
    {
      'img': 'assets/img/catscratchpost.png',
      'name': 'Pawise Cat Post Corner Kail',
      'price': 15.20,
      'desc':
          'High quality scratch post to meet your cat\'s scratching needs. Product Dimension: 29 x 28 x 42 cm',
      'stock': 14,
      'rating': 4.6,
    },
    {
      'img': 'assets/img/wheelfeeder.png',
      'name': 'Cattyman 1221 Cat Toy - Interactive Cat Wheel Feeder',
      'price': 23.90,
      'desc':
          'A cat wheel feeder that helps stimulate your cat\'s mind as your cat strives to solve the challenge and get their food or treats. The feeder spins and ejects food or treats when your pet turns it. This spinning feeder makes feeding time more fun for your cat and helps slow its eating pace.',
      'stock': 17,
      'rating': 4.8,
    },
    {
      'img': 'assets/img/catlitterbox.png',
      'name':
          'Large Capacity Cat Litter Box Semi-closed Sand Box for Cats Toilet Anti Splash Cat Tray Gift scooper',
      'price': 10.40,
      'desc':
          'The cat litter box adopts raised 86mm fence and detachable structure, which can can easily filter cat litter and is convenient for you to clean.',
      'stock': 14,
      'rating': 4.9,
    },
  ];

  final List<Map<String, dynamic>> groomingProducts = [
    {
      'img': 'assets/img/dogshampoo.png',
      'name':
          'Cleansing & Moisturizing Shampoo 400ml & Nourishing Detangling Conditioner for Dogs 400ml | Sulphate & Paraben free',
      'price': 10.50,
      'desc':
          'Keep your dog\'s coat clean, hydrated, and silky smooth with Petterati Cleansing & Moisturizing Shampoo and Nourishing Detangling Conditioner. Formulated with oatmeal, this moisturizing shampoo hydrates and soothes sensitive skin while cleansing effectively. It leaves your dog\'s coat soft, shiny, and comfortable. ',
      'stock': 32,
      'rating': 4.2,
    },
    {
      'img': 'assets/img/doggroomingkit.png',
      'name':
          'Dog Grooming Kit, Pet Foot Shaver, Low Noise Rechargeable Cordless Pet Hair Trimmer',
      'price': 70.00,
      'desc':
          '1 x Pet Hair Trimmer, 1 x Stainless Steel Scissors, 1 x Nail File, 1 x Stainless Steel Comb, 1 x Nail Clipper, 1 x Cleaning Brush, 1 x Lubricating Oil, 4 x Guide Comb( (3mm, 6mm, 9mm, 12mm), 1 x USB Cable (Not include charge adapters).',
      'stock': 25,
      'rating': 4.3,
    },
    {
      'img': 'assets/img/salmonoilfordogsandcats.png',
      'name':
          'Wild Alaskan Fish Oil for Dogs & Cats - Omega 3 EPA DHA | Zesty Paws',
      'price': 35.00,
      'desc':
          'Premium Wild Alaskan Fish Oil blend with Pollock & Salmon oils. Rich in EPA & DHA omega-3s for healthy skin, coat, and immune support. Easy-to-use pump dispenser for dogs and cats.',
      'stock': 37,
      'rating': 4.6,
    },
    {
      'img': 'assets/img/bamboocomb.png',
      'name': 'ARTERO Bamboo Slicker, Regular Pin',
      'price': 25.20,
      'desc':
          'Ideal for brushing dense or shedding coats and effective for tangles and knots thanks to the length, thickness and semi-flexibility of the bristles.',
      'stock': 47,
      'rating': 4.3,
    },
    {
      'img': 'assets/img/petwipes.png',
      'name': 'Petkin Petwipes For Pet (100 pcs)',
      'price': 28.60,
      'desc':
          'Veterinarian approved Pet Wipes provide a fast, convenient way to keep your pet clean and healthy everyday. Each pet wipe is moistened with a gentle cleansing formula that helps maintain a clean and healthy pet coat while restoring skin moisture and softness. Use daily for quick cleanings, controlling pet odors and wiping dirty paws.',
      'stock': 87,
      'rating': 4.2,
    },
  ];

  void _showItemPopup(BuildContext context, Map<String, dynamic> product) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, dialogsetState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        product['img'],
                        height: 360,
                        width: 360,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.brown.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'SGD \$${product['price']}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    product['desc'],
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Only ${product['stock']} left',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.yellow.shade700,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${product['rating']}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              dialogsetState(() {
                                quantity--;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.orange.shade600,
                            size: 30,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$quantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (quantity < product['stock']) {
                              dialogsetState(() {
                                quantity++;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.pets, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Maximum stock reached'),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange.shade600,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.orange.shade600,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final existingIndex = cart.indexWhere(
                              (item) => item['name'] == product['name'],
                            );

                            setState(() {
                              if (existingIndex != -1) {
                                cart[existingIndex]['quantity'] += quantity;
                              } else {
                                cart.add({...product, 'quantity': quantity});
                              }
                            });

                            final uid =
                                FirebaseAuth.instance.currentUser?.uid ?? '';
                            if (uid.isNotEmpty) {
                              final cartRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('cart')
                                  .doc('current');
                              await cartRef.set({'items': cart});
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Added to cart!'),
                                  ],
                                ),
                                backgroundColor: Colors.green.shade600,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.shopping_cart_outlined),
                          label: Text('ADD TO CART'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  cartItems: [
                                    {...product, 'quantity': quantity},
                                  ],
                                  onCartChanged: (updatedCart) {
                                    setState(() {
                                      cart = updatedCart;
                                    });
                                  },
                                ),
                              ),
                            );

                            if (result == true) {
                              setState(() {
                                cart.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.flash_on),
                          label: Text('BUY NOW'),
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
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _showItemPopup(context, product),
      child: Container(
        width: 500,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.orange.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    product['img'],
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Flexible(
                child: Text(
                  product['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.brown.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'SGD \$${product['price']}',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.yellow.shade700),
                  SizedBox(width: 2),
                  Text(
                    '${product['rating']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Map<String, dynamic>> products,
    IconData icon,
  ) {
    final ScrollController scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.orange.shade700, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              ListView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                children: products
                    .map((p) => _buildProductCard(context, p))
                    .toList(),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  alignment: Alignment.center,
                  color: Colors.white.withOpacity(0.5),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () {
                      final newOffset = (scrollController.offset - 200).clamp(
                        0.0,
                        scrollController.position.maxScrollExtent,
                      );
                      scrollController.animateTo(
                        newOffset,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  alignment: Alignment.center,
                  color: Colors.white.withOpacity(0.5),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 20),
                    onPressed: () {
                      final newOffset = (scrollController.offset + 200).clamp(
                        0.0,
                        scrollController.position.maxScrollExtent,
                      );
                      scrollController.animateTo(
                        newOffset,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Pet Essentials',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${cart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 1))}',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(
                      cartItems: List<Map<String, dynamic>>.from(cart),
                      onCartChanged: (updatedCart) {
                        setState(() {
                          cart = updatedCart;
                        });
                      },
                    ),
                  ),
                );

                if (result == true) {
                  setState(() {
                    cart.clear();
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.yellow.shade100],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pets, size: 30, color: Colors.orange.shade700),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Everything your furry friends need!',
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
              _buildSection('Dog Essentials', dogProducts, Icons.pets),
              _buildSection('Cat Essentials', catProducts, Icons.pets),
              _buildSection(
                'Grooming Essentials',
                groomingProducts,
                Icons.content_cut,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
