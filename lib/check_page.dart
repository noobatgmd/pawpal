import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

class CheckPage extends StatefulWidget {
  @override
  _CheckPageState createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String? safetyMessage;
  int? safetyLevel;
  bool _isSearching = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, Map<String, dynamic>> ingredientSafetyData = {
    //LEVEL 5: Very Harmful
    'chocolate': {
      'level': 5,
      'message':
          'Chocolate contains caffeine and theobromine, which stimulate the nervous system and heart. DO NOT FEED!',
      'icon': Icons.dangerous,
    },
    'grape': {
      'level': 5,
      'message': 'Grapes may cause kidney failure in dogs. DO NOT FEED!',
      'icon': Icons.dangerous,
    },
    'raisins': {
      'level': 5,
      'message': 'Raisins may cause kidney failure in dogs. DO NOT FEED!',
      'icon': Icons.dangerous,
    },
    'onions': {
      'level': 5,
      'message':
          'Onions contains compounds, specifically N-propyl disulfide, that damage red blood cells, leading to anemia',
      'icon': Icons.dangerous,
    },
    'garlic': {
      'level': 5,
      'message':
          'Garlic contains a compound called thiosulfate that damage red blood cells which are responsible for carrying oxygen around the body.',
      'icon': Icons.dangerous,
    },
    'xylitol': {
      'level': 5,
      'message':
          'Xylitol can cause hypoglycaemia (low blood sugar levels) as the pancreas will confuse it with real sugar, which makes it release more insulin. The insulin then removes the real sugar in the body, leading to plummeting blood sugar levels.',
      'icon': Icons.dangerous,
    },
    'macadamia nuts': {
      'level': 5,
      'message':
          'Macadamia nuts can cause tremors, vomiting, and hyperthermia in dogs. Highly toxic.',
      'icon': Icons.dangerous,
    },
    'alcohol': {
      'level': 5,
      'message':
          'Alcohol can depress the nervous system, leading to vomiting, seizures, or death.',
      'icon': Icons.dangerous,
    },
    'caffeine': {
      'level': 5,
      'message':
          'Caffeine overstimulates the heart and nervous system. Even small doses can be dangerous.',
      'icon': Icons.dangerous,
    },
    'avocado': {
      'level': 5,
      'message': 'Contains persin, which is toxic to dogs.',
      'icon': Icons.dangerous,
    },
    'moldy food': {
      'level': 5,
      'message': 'Can contain tremorgenic mycotoxins. DO NOT FEED.',
      'icon': Icons.dangerous,
    },
    'yeast dough': {
      'level': 5,
      'message':
          'Expands in the stomach and can cause bloat or alcohol poisoning.',
      'icon': Icons.dangerous,
    },
    'cherry pits': {
      'level': 5,
      'message': 'Contain cyanide and can block intestines.',
      'icon': Icons.dangerous,
    },
    'candy': {
      'level': 5,
      'message': 'Often contains xylitol or sugar, both harmful to dogs.',
      'icon': Icons.dangerous,
    },
    //LEVEL 4: Harmful
    'cooked bones': {
      'level': 4,
      'message':
          'Cooked bones can splinter and cause choking, internal injuries, or blockages.',
      'icon': Icons.warning,
    },
    'raw dough': {
      'level': 4,
      'message':
          'Unbaked yeast dough can expand in the stomach and produce alcohol.',
      'icon': Icons.warning,
    },
    'salt': {
      'level': 4,
      'message':
          'Too much salt causes dehydration and may lead to sodium ion poisoning.',
      'icon': Icons.warning,
    },
    'milk': {
      'level': 4,
      'message':
          'Many dogs are lactose intolerant. Milk can cause diarrhea and gas.',
      'icon': Icons.warning,
    },
    'fat trimmings': {
      'level': 4,
      'message':
          'Excess fat can lead to pancreatitis and obesity-related issues.',
      'icon': Icons.warning,
    },
    'butter': {
      'level': 4,
      'message': 'High in fat and can cause pancreatitis. Not recommended.',
      'icon': Icons.warning,
    },
    'nutmeg': {
      'level': 4,
      'message': 'Contains myristicin which can be toxic to dogs.',
      'icon': Icons.warning,
    },
    'mustard': {
      'level': 4,
      'message': 'Irritates the digestive system.',
      'icon': Icons.warning,
    },
    'bacon': {
      'level': 4,
      'message': 'Too much fat and salt. Risk of pancreatitis.',
      'icon': Icons.warning,
    },
    //LEVEL 3: Eat in moderation
    'cheese': {
      'level': 3,
      'message': 'Feed in moderation. Some dogs are lactose intolerant.',
      'icon': Icons.info,
    },
    'peanut butter': {
      'level': 3,
      'message': 'Safe if xylitol-free. High in fat — feed in moderation.',
      'icon': Icons.info,
    },
    'tomato': {
      'level': 3,
      'message':
          'Ripe tomatoes are okay, but avoid green parts (contain solanine).',
      'icon': Icons.info,
    },
    'popcorn': {
      'level': 3,
      'message': 'Only plain, air-popped. Avoid butter, salt, and seasoning.',
      'icon': Icons.info,
    },
    'bread': {
      'level': 3,
      'message':
          'Plain white or wheat bread is okay occasionally. No raisins or garlic.',
      'icon': Icons.info,
    },
    'corn': {
      'level': 3,
      'message':
          'Plain, cooked corn is okay. Avoid corn cobs as it is a choking hazard.',
      'icon': Icons.info,
    },
    'yogurt': {
      'level': 3,
      'message': 'Plain yogurt is fine if your dog is not lactose intolerant.',
      'icon': Icons.info,
    },
    'beef': {
      'level': 3,
      'message': 'Cooked beef is safe, but avoid fatty or seasoned cuts.',
      'icon': Icons.info,
    },
    'french fries': {
      'level': 3,
      'message':
          'Too salty and oily. A few plain fries are okay once in a while.',
      'icon': Icons.info,
    },
    //LEVEL 2: Safe
    'apple': {
      'level': 2,
      'message': 'Apples are generally safe for dogs. Avoid seeds.',
      'icon': Icons.check_circle_outline,
    },
    'banana': {
      'level': 2,
      'message': 'Bananas are rich in potassium. Serve in small portions.',
      'icon': Icons.check_circle_outline,
    },
    'broccoli': {
      'level': 2,
      'message': 'Safe in small amounts. High fiber, but may cause gas.',
      'icon': Icons.check_circle_outline,
    },
    'eggs': {
      'level': 2,
      'message': 'Cooked eggs are safe and a good source of protein.',
      'icon': Icons.check_circle_outline,
    },
    'strawberries': {
      'level': 2,
      'message': 'Sweet and safe. Rich in fiber and vitamin C.',
      'icon': Icons.check_circle_outline,
    },
    'watermelon': {
      'level': 2,
      'message': 'Hydrating treat. Remove seeds and rind.',
      'icon': Icons.check_circle_outline,
    },
    'pineapple': {
      'level': 2,
      'message': 'Safe in small amounts. Rich in vitamins and enzymes.',
      'icon': Icons.check_circle_outline,
    },
    'peas': {
      'level': 2,
      'message': 'Safe and nutritious. Avoid canned peas with added salt.',
      'icon': Icons.check_circle_outline,
    },
    'spinach': {
      'level': 2,
      'message': 'Contains iron and fiber. Feed in moderation due to oxalates.',
      'icon': Icons.check_circle_outline,
    },
    //LEVEL 1: Very Safe
    'carrot': {
      'level': 1,
      'message': 'Very safe and good for dental health. Low calorie.',
      'icon': Icons.check_circle,
    },
    'pumpkin': {
      'level': 1,
      'message': 'Great for digestion. Use plain, cooked pumpkin.',
      'icon': Icons.check_circle,
    },
    'rice': {
      'level': 1,
      'message': 'Easily digestible. Often used in bland diets.',
      'icon': Icons.check_circle,
    },
    'chicken': {
      'level': 1,
      'message': 'Boiled, unseasoned chicken is a healthy protein for dogs.',
      'icon': Icons.check_circle,
    },
    'sweet potato': {
      'level': 1,
      'message': 'Rich in fiber and nutrients. Must be cooked and plain.',
      'icon': Icons.check_circle,
    },
    'blueberries': {
      'level': 1,
      'message': 'Rich in antioxidants and vitamins. Great low-calorie treat.',
      'icon': Icons.check_circle,
    },
    'cucumber': {
      'level': 1,
      'message': 'Hydrating and low in calories. Good crunchy snack.',
      'icon': Icons.check_circle,
    },
    'zucchini': {
      'level': 1,
      'message': 'Low in fat and cholesterol. A healthy veggie for dogs.',
      'icon': Icons.check_circle,
    },
    'celery': {
      'level': 1,
      'message':
          'Contains fiber and vitamins A, C, and K. Safe in small pieces.',
      'icon': Icons.check_circle,
    },
    'green beans': {
      'level': 1,
      'message': 'Full of fiber and vitamins. A healthy filler in meals.',
      'icon': Icons.check_circle,
    },
  };

  final List<Map<String, dynamic>> safetyScale = [
    {
      'label': 'Very Safe',
      'color': Color(0xFF2E7D32),
      'bgColor': Color(0xFFE8F5E8),
      'emoji': '✅',
    },
    {
      'label': 'Safe',
      'color': Color(0xFF388E3C),
      'bgColor': Color(0xFFE8F5E8),
      'emoji': '👍',
    },
    {
      'label': 'Eat in Moderation',
      'color': Color(0xFFF57C00),
      'bgColor': Color(0xFFFFF3E0),
      'emoji': '⚠️',
    },
    {
      'label': 'Harmful',
      'color': Color(0xFFE64A19),
      'bgColor': Color(0xFFFFEBEE),
      'emoji': '❌',
    },
    {
      'label': 'Extremely Harmful',
      'color': Color(0xFFD32F2F),
      'bgColor': Color(0xFFFFEBEE),
      'emoji': '🚫',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void checkIngredient() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter an ingredient first!'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      safetyLevel = null;
      safetyMessage = null;
    });

    // Simulate search delay for better UX
    await Future.delayed(Duration(milliseconds: 800));

    final input = _controller.text.trim();

    // First: Try exact match (case-insensitive)
    final match = ingredientSafetyData.keys.firstWhere(
      (key) => key.toLowerCase() == input.toLowerCase(),
      orElse: () => '',
    );

    if (match.isNotEmpty) {
      setState(() {
        _isSearching = false;
        safetyLevel = ingredientSafetyData[match]!['level'];
        safetyMessage = ingredientSafetyData[match]!['message'];
      });

      if (safetyLevel! >= 4) {
        _pulseController.repeat(reverse: true);
      }
      return;
    }

    // Second: Try fuzzy match
    double bestMatchScore = 0;
    String bestMatchKey = '';

    ingredientSafetyData.keys.forEach((key) {
      final score = StringSimilarity.compareTwoStrings(
        input.toLowerCase(),
        key.toLowerCase(),
      );
      if (score > bestMatchScore) {
        bestMatchScore = score;
        bestMatchKey = key;
      }
    });

    setState(() {
      _isSearching = false;
    });

    if (bestMatchScore > 0.6) {
      // Accept fuzzy match
      setState(() {
        safetyLevel = ingredientSafetyData[bestMatchKey]!['level'];
        safetyMessage = ingredientSafetyData[bestMatchKey]!['message'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Did you mean "${bestMatchKey}"?')),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );

      if (safetyLevel! >= 4) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      // No match found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.search_off, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Ingredient not found. Try a different spelling!'),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.pets, size: 48, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      '🐕 Dog Food Safety Checker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check if ingredients are safe for your furry friend',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Search Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Enter ingredient name',
                        hintText: 'e.g., chocolate, apple, chicken...',
                        prefixIcon: Icon(Icons.search, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onSubmitted: (_) => checkIngredient(),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : checkIngredient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isSearching
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Checking...',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Check Safety',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Result Section
              if (safetyMessage != null && safetyLevel != null)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final scale = safetyLevel! >= 4
                        ? _pulseAnimation.value
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: safetyScale[safetyLevel! - 1]['bgColor'],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: safetyScale[safetyLevel! - 1]['color'],
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: safetyScale[safetyLevel! - 1]['color']
                                  .withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        safetyScale[safetyLevel! - 1]['color'],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    ingredientSafetyData.values.firstWhere(
                                      (data) => data['level'] == safetyLevel,
                                    )['icon'],
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            safetyScale[safetyLevel! -
                                                1]['emoji'],
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              safetyLevel == 5
                                                  ? 'EXTREMELY HARMFUL - DO NOT FEED!'
                                                  : safetyScale[safetyLevel! -
                                                        1]['label'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    safetyScale[safetyLevel! -
                                                        1]['color'],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        safetyMessage!,
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.4,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              SizedBox(height: 32),

              // Safety Scale Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Safety Scale Guide",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ...safetyScale.asMap().entries.map((entry) {
                      final index = entry.key;
                      final scale = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scale['bgColor'],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: scale['color'].withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              scale['emoji'],
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: scale['color'],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                scale['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: scale['color'],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Future Enhancement Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purple),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Future Enhancement",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Scan ingredient lists with OCR technology (Google ML Kit)",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.purple[600],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
