import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mad_ca3/book_appointment_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // for Clipboard

class GroomPage extends StatefulWidget {
  @override
  _GroomPageState createState() => _GroomPageState();
}

class _GroomPageState extends State<GroomPage> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  late MapController _mapController = MapController();
  String _searchText = '';
  List<Map<String, dynamic>> _selectedGrooms = [];
  late TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedGroom;

  final List<Map<String, dynamic>> grooms = [
    {
      'name': 'Doggylicious (Est. 2011) - Dog grooming service',
      'lat': 1.3625997178809248,
      'lng': 103.851029224637,
      'address': 'Ang Mo Kio Ave 1, #01-1831 Block 330, Singapore 560330',
      'rating': 4.6,
      'tel': '94771804',
      'mapUrl': 'https://maps.app.goo.gl/XTjy1Z6Ack628unh9',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name':
          'The Pets Workshop (Nex) - Dogs & Cats Grooming / Pet Spa Services in Serangoon Nex Mall',
      'lat': 1.3512639673919387,
      'lng': 103.87191922463694,
      'address': '23, Serangoon Central, #04-03 & #04-71, 556083',
      'rating': 4.9,
      'tel': '98348946',
      'mapUrl': 'https://maps.app.goo.gl/t7Jw5mo6pNUAyvDT7',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'The Blep Club Cat & Dog Salon, Bedok Reservoir',
      'lat': 1.338664320440378,
      'lng': 103.92228413813035,
      'address': '742 Bedok Reservoir Rd, #01-3121, Singapore 470742',
      'rating': 5.0,
      'tel': '83135853',
      'mapUrl': 'https://maps.app.goo.gl/VkUL2GAX9ETNPT8s9',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Hanis The Groomer - Cat Grooming Service',
      'lat': 1.3529184312352558,
      'lng': 103.95202323147959,
      'address': '264 Tampines St. 21, #01-114 Block 264, Singapore 520264',
      'rating': 4.8,
      'tel': '91001737',
      'mapUrl': 'https://maps.app.goo.gl/5GCS4vGcDneGoJQ16',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Bubbly',
      'lat': 1.3103651414567221,
      'lng': 103.90173211746664,
      'address': '290R Joo Chiat Rd, Singapore 427542',
      'rating': 4.5,
      'tel': '96563786',
      'mapUrl': 'https://maps.app.goo.gl/w9n2dhiuXKqp4nvX6',
      'open': '09:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Wagnwhiskers Pet Grooming',
      'lat': 1.2826410268565471,
      'lng': 103.78600555131622,
      'address':
          'South Buona Vista Rd, B1-50 Viva Vista Shopping Mall, 3, Singapore 118136',
      'rating': 4.9,
      'tel': '97749788',
      'mapUrl': 'https://maps.app.goo.gl/N2qVaginQRQ15CUA7',
      'open': '11:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Pet Autumn',
      'lat': 1.34338,
      'lng': 103.70558,
      'address': '8 Jln Legundi #01-11, Singapore 759274 ',
      'rating': 5.0,
      'tel': '80334489 ',
      'mapUrl': 'https://maps.app.goo.gl/48Hcz1rC8Dpuxwug9',
      'open': '10:00',
      'close': '17:00',
      'tempClosed': false,
    },

    {
      'name': 'Paws N\' Claws Veterinary Surgery (Medical Grooming Centre)',
      'lat': 1.44028,
      'lng': 103.83929,
      'address': '285 Yishun Ave 6, #01-06, Singapore 760285',
      'rating': 4.1,
      'tel': '88090787 ',
      'mapUrl': 'https://maps.app.goo.gl/bqU84U1AqkgrbndK7',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },

    {
      'name': 'The Cut Pet Grooming & Spa',
      'lat': 1.35549,
      'lng': 103.88800,
      'address': '183 Jln Pelikat, #B1-62 The Promenade, Singapore 537643',
      'rating': 5.0,
      'tel': '90281336',
      'mapUrl': 'https://maps.app.goo.gl/wm4a2Uz2p3jEZ8Uk9',
      'open': '11:00',
      'close': '18:00',
      'tempClosed': false,
    },

    {
      'name': 'Pet Loft',
      'lat': 1.34823,
      'lng': 103.88013,
      'address':
          '371 Upper Paya Lebar Rd, #01-02 Yi Kai Court, Singapore 534969',
      'rating': 4.9,
      'tel': '64874669',
      'mapUrl': 'https://maps.app.goo.gl/RNfLRa1usEq433MJA',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Art of Pets',
      'lat': 1.31084,
      'lng': 103.88049,
      'address': '94 Guillemard Rd, Singapore 399717',
      'rating': 4.8,
      'tel': '97477889',
      'mapUrl': 'https://maps.app.goo.gl/j2p4q9TrwfcMEK4j9',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'My Pet Image',
      'lat': 1.42800,
      'lng': 103.83728,
      'address': '925 Yishun Central 1, #01-223/225, Singapore 760925',
      'rating': 4.7,
      'tel': '67588675',
      'mapUrl': 'https://maps.app.goo.gl/ScnXzPQmneGrpUfC8',
      'open': '11:00',
      'close': '17:00',
      'tempClosed': false,
    },
    {
      'name': 'Ohana Singapaws',
      'lat': 1.43095,
      'lng': 103.77951,
      'address': '325 Woodlands Street 32, #01-135, Singapore 730325',
      'rating': 4.8,
      'tel': '82983378',
      'mapUrl': 'https://maps.app.goo.gl/XSuavMHCkPKc4KGYA',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Nekomori Cat Salon',
      'lat': 1.44316,
      'lng': 103.82576,
      'address': '59D Jln Malu-malu, Singapore 769674',
      'rating': 4.9,
      'tel': '66558693',
      'mapUrl': 'https://maps.app.goo.gl/mvELZUFGBfN8cDzp6',
      'open': '11:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Scruffiez',
      'lat': 1.35340,
      'lng': 103.88628,
      'address': 'Blk 123 Hougang Ave 1, #01-1422, Singapore 530123',
      'rating': 4.7,
      'tel': '98770772',
      'mapUrl': 'https://maps.app.goo.gl/sTW1ve6qNbTdLMw26',
      'open': '11:00',
      'close': '17:30',
      'tempClosed': false,
    },
    {
      'name': 'Pawtraits',
      'lat': 1.35838,
      'lng': 103.87483,
      'address': '96 Yio Chu Kang Rd, Singapore 545574',
      'rating': 4.6,
      'tel': '88622211',
      'mapUrl': 'https://maps.app.goo.gl/dH7tABhE7Uyt3jWn9',
      'open': '09:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Pawpy Kisses Pet Shop & Pet Grooming Services',
      'lat': 1.32173,
      'lng': 103.85333,
      'address': '232 Balestier Rd, Singapore 329694',
      'rating': 4.9,
      'tel': '90606501',
      'mapUrl': 'https://maps.app.goo.gl/wvwaA2GeYy7Spnp46',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'The Furville Salon',
      'lat': 1.29744,
      'lng': 103.84321,
      'address': '71 Oxley Rise, #01-07 The Rise @ Oxley, Singapore 238698',
      'rating': 4.5,
      'tel': '86882758',
      'mapUrl': 'https://maps.app.goo.gl/S1GAhy4VGYXERTYt8',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Big Paws Small Paws',
      'lat': 1.31379,
      'lng': 103.85385,
      'address': '109 Owen Rd, Singapore 218916',
      'rating': 5.0,
      'tel': '88313723',
      'mapUrl': 'https://maps.app.goo.gl/cPQrtpMSqgrxCGGv6',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'June\'s Pet House',
      'lat': 1.33663,
      'lng': 103.76875,
      'address': '5 Eng Kong Terrace, Singapore 598977',
      'rating': 4.7,
      'tel': '84445777',
      'mapUrl': 'https://maps.app.goo.gl/SoaJUUr4q1wvFBBb8',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Takara Pets',
      'lat': 1.44653,
      'lng': 103.80633,
      'address': '785e Woodlands Rise, #01-10, Singapore 735785',
      'rating': 4.9,
      'tel': '91157157',
      'mapUrl': 'https://maps.app.goo.gl/YhM9oLbLoXkCJ29c9',
      'open': '12:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'OBD Hut',
      'lat': 1.34480,
      'lng': 103.73905,
      'address': '257 Jurong East St 24, Singapore 600257',
      'rating': 5.0,
      'tel': '91455054',
      'mapUrl': 'https://maps.app.goo.gl/a4kPUEFzLbgUcRyq9',
      'open': '09:00',
      'close': '17:00',
      'tempClosed': false,
    },
    {
      'name': 'The Grooming Table',
      'lat': 1.28733,
      'lng': 103.81390,
      'address': '55 Lengkok Bahru, #01-391, Singapore 151055',
      'rating': 4.6,
      'tel': '62502938',
      'mapUrl': 'https://maps.app.goo.gl/9e745zT9ZQdcAmZB6',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'The Grooming Angels',
      'lat': 1.30638,
      'lng': 103.90202,
      'address': '31A E Coast Rd, Singapore 428752',
      'rating': 4.7,
      'tel': '67709800',
      'mapUrl': 'https://maps.app.goo.gl/uzpR3UThz1Pk8pyh6',
      'open': '10:30',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Likeable Pets',
      'lat': 1.33408,
      'lng': 103.88607,
      'address': '18 Howard Rd, Singapore 369585',
      'rating': 5.0,
      'tel': '86852360',
      'mapUrl': 'https://maps.app.goo.gl/ovPe937EEt12sQnT6',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Surrpaws',
      'lat': 1.4506412303702616,
      'lng': 103.82669886732356,
      'address': '590 Montreal Link, Singapore 750590',
      'rating': 5.0,
      'tel': '88457183',
      'mapUrl': 'https://maps.app.goo.gl/JFQyKEMsyfP1PPQ49',
      'open': '09:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Furkids Home Pet Grooming & Spa',
      'lat': 1.3293160056565518,
      'lng': 103.93112358348691,
      'address': 'Bedok North Ave 2, #01-136 Block 412, Singapore 460412',
      'rating': 3.9,
      'tel': '90460410',
      'mapUrl': 'https://maps.app.goo.gl/T6cqnEgLBU97Sz7o7',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Pooch Image | Pet Shop & Pet Grooming Singapore',
      'lat': 1.3135760369209475,
      'lng': 103.9293828634234,
      'address': '119 Upper E Coast Rd, #01-01, Singapore 455244',
      'rating': 4.6,
      'tel': '63444044',
      'mapUrl': 'https://maps.app.goo.gl/LsZuFrvk8RaLmHUB6',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Inu Town',
      'lat': 1.3522611023939772,
      'lng': 103.835007144418,
      'address': '215K Upper Thomson Rd, Singapore 574349',
      'rating': 4.8,
      'tel': '87696118',
      'mapUrl': 'https://maps.app.goo.gl/mK7MZNFNaHqDfUV27',
      'open': '12:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'The Precious Pets Mobile Pet Grooming Services',
      'lat': 1.3631094321034114,
      'lng': 103.7489452912011,
      'address': '337 Bukit Batok Street 34, Singapore 650337',
      'rating': 4.7,
      'tel': '96973337',
      'mapUrl': 'https://maps.app.goo.gl/N772AoRWozYdg4dF7',
      'open': '10:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Pawcious Style',
      'lat': 1.4273531534460175,
      'lng': 103.82627667790707,
      'address': '403 Sembawang Rd, Singapore 758384',
      'rating': 4.6,
      'tel': '88935642',
      'mapUrl': 'https://maps.app.goo.gl/BYLuWXLQhkzhJW826',
      'open': '10:30',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'PetPat Jalan Pelikat - Cat Grooming Salon',
      'lat': 1.3554856190017799,
      'lng': 103.88817137779388,
      'address': '183 Jln Pelikat, #B1-41 The Promenade, Singapore 537643',
      'rating': 4.9,
      'tel': '82991040',
      'mapUrl': 'https://maps.app.goo.gl/ABQDcDqCEVgpQYTt5',
      'open': '11:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'The Lovely Pets Puppies Singapore',
      'lat': 1.3650358916920564,
      'lng': 103.87549345520112,
      'address': '46 Jln Limbok, Singapore 548728',
      'rating': 4.5,
      'tel': '90472718',
      'mapUrl': 'https://maps.app.goo.gl/P4QeigvbMYNXsMSf6',
      'open': '09:30',
      'close': '18:30',
      'tempClosed': false,
    },
    {
      'name': 'Kawaii Pets Pte. Ltd.',
      'lat': 1.3709779747725432,
      'lng': 103.84324311873561,
      'address': '128 Ang Mo Kio Ave 3, #01-1845, Singapore 560128',
      'rating': 4.6,
      'tel': '64554990',
      'mapUrl': 'https://maps.app.goo.gl/btHuKxUVv6ppQEwTA',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'The Pup Life SG',
      'lat': 1.3322961876865047,
      'lng': 103.8833882227882,
      'address': '496 MacPherson Rd, Singapore 368201',
      'rating': 5.0,
      'tel': '88022124',
      'mapUrl': 'https://maps.app.goo.gl/TZjL4dzf5EBkdBrt6',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'Hey Good Cat',
      'lat': 1.3104470672154065,
      'lng': 103.90177016881452,
      'address': '290R Joo Chiat Rd, Singapore 427542',
      'rating': 4.6,
      'tel': '96563786',
      'mapUrl': 'https://maps.app.goo.gl/s67DadT6iGGBNeec8',
      'open': '09:00',
      'close': '18:00',
      'tempClosed': false,
    },
    {
      'name': 'Pet\'s Lagoon',
      'lat': 1.3777193677120476,
      'lng': 103.74436180929487,
      'address': 'Choa Chu Kang Ave 1, #01-16 Block 253, Singapore 680253',
      'rating': 4.2,
      'tel': '67600376',
      'mapUrl': 'https://maps.app.goo.gl/dkzfJuM4DgtXLpf97',
      'open': '10:00',
      'close': '20:00',
      'tempClosed': false,
    },
    {
      'name': 'PetLoft',
      'lat': 1.348246900502639,
      'lng': 103.88004594408429,
      'address':
          '371 Upper Paya Lebar Rd, #01-02 Yi Kai Court, Singapore 534969',
      'rating': 4.9,
      'tel': '64874669',
      'mapUrl': 'https://maps.app.goo.gl/2Lk5nqBgvLyw6ddN8',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Pets Eden Spa & Salon',
      'lat': 1.3323511730146835,
      'lng': 103.92701873234998,
      'address': 'Blk 551 Bedok North Ave 1, #01-552, Singapore 460551',
      'rating': 4.5,
      'tel': '92277915',
      'mapUrl': 'https://maps.app.goo.gl/3d5WTkYNWbNQX4R58',
      'open': '10:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Dollhouse Pets',
      'lat': 1.2772994215771325,
      'lng': 103.83682096114572,
      'address': '7 Kampong Bahru Rd, Singapore 169342',
      'rating': 4.8,
      'tel': '64989820',
      'mapUrl': 'https://maps.app.goo.gl/XfkC2oBuBC6VHbD89',
      'open': '11:00',
      'close': '19:00',
      'tempClosed': false,
    },
  ];

  double _currentZoom = 13.0;
  Map<String, dynamic>? _zoomTargetGroom;

  bool _isTempClosed(Map<String, dynamic> p) => (p['tempClosed'] == true);
  bool _hasHours(Map<String, dynamic> p) =>
      p.containsKey('open') || p.containsKey('close');
  bool _is24H(Map<String, dynamic> p) =>
      (p['open'] ?? '').toString().toUpperCase() == '24H' ||
      (p['close'] ?? '').toString().toUpperCase() == '24H';

  int? _toMinutes(String? hhmm) {
    if (hhmm == null) return null;
    final s = hhmm.trim();
    if (s.isEmpty || s.toUpperCase() == '24H') return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  bool _isOpenNow(Map<String, dynamic> p) {
    if (_isTempClosed(p)) return false;
    if (!_hasHours(p)) return true;
    if (_is24H(p)) return true;

    final now = DateTime.now();
    final minutesNow = now.hour * 60 + now.minute;

    final openMin = _toMinutes(p['open']?.toString());
    final closeMin = _toMinutes(p['close']?.toString());
    if (openMin == null || closeMin == null) return true;

    if (closeMin > openMin) {
      return minutesNow >= openMin && minutesNow < closeMin;
    } else {
      return minutesNow >= openMin || minutesNow < closeMin;
    }
  }

  String _statusText(Map<String, dynamic> p) {
    if (_isTempClosed(p)) return 'Temporarily closed';
    if (!_hasHours(p)) return 'Status unknown';
    if (_is24H(p)) return 'Open 24 hours';
    return _isOpenNow(p) ? 'Open now' : 'Closed now';
  }

  String _hoursLine(Map<String, dynamic> p) {
    if (_isTempClosed(p)) return 'Hours: —';
    if (!_hasHours(p)) return 'Hours: Unknown';
    if (_is24H(p)) return 'Hours: 24 hours';
    return 'Hours: ${p['open']}-${p['close']}';
  }

  Color _markerColor(Map<String, dynamic> p) {
    if (_isTempClosed(p)) return Colors.black;
    if (!_hasHours(p)) return Colors.blue;
    if (_is24H(p)) return Colors.red;
    return _isOpenNow(p) ? Colors.red : Colors.amber;
  }

  List<Map<String, dynamic>> get _filteredGrooms {
    if (_searchText.isEmpty) {
      return grooms;
    }
    return grooms
        .where(
          (groom) => groom['name'].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          ),
        )
        .toList();
  }

  void _updateSelectedGrooms(LatLng center) {
    const double maxDistanceMeters = 1000; // 1km radius for example
    setState(() {
      _selectedGrooms = _filteredGrooms.where((Groom) {
        final GroomLatLng = LatLng(Groom['lat'], Groom['lng']);
        final Distance distanceCalculator = Distance();
        final distance = distanceCalculator(
          center,
          GroomLatLng,
        ); // Using latlong2 package distance
        return distance <= maxDistanceMeters;
      }).toList();
    });
  }

  LatLng? _currentCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _currentCenter = const LatLng(1.3521, 103.8198);
    _updateSelectedGrooms(_currentCenter!);
    _searchController.addListener(() {
      final text = _searchController.text.toLowerCase();
      setState(() {
        _searchText = text;

        if (text.isEmpty) {
          _selectedGroom = null;
          _showSuggestions = false;
          _suggestions = [];
        } else {
          _showSuggestions = true;
          _suggestions = grooms.where((item) {
            final name = item['name'].toString().toLowerCase();
            return name.contains(text);
          }).toList();

          if (_currentCenter != null) {
            _updateSelectedGrooms(_currentCenter!);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchAndZoom() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    // Search in filtered or all list (use filtered to support partial search)
    Map<String, dynamic>? match;
    for (var item in _filteredGrooms) {
      final name = item['name'].toString().toLowerCase();
      if (name.contains(query)) {
        match = item;
        break;
      }
    }

    if (match != null) {
      final lat = match['lat'] as double;
      final lng = match['lng'] as double;
      final target = LatLng(lat, lng);

      // Move the map
      _mapController.move(target, 17);

      // Update selected item to show sliding card
      setState(() {
        _selectedGroom = match;
      });
    } else {
      // Optionally show a message if no match found
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No matching Groom found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.cut_outlined, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Groom Shops in Singapore',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showSuggestions ? 208 : 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Grooms by name...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _searchAndZoom();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onSubmitted: (value) {
                    _searchAndZoom();
                  },
                ),
                if (_showSuggestions)
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          title: Text(item['name']),
                          onTap: () {
                            _searchController.text = item['name'];
                            _searchAndZoom();
                            setState(() {
                              _showSuggestions = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(1.3521, 103.8198),
              initialZoom: 12,
              onPositionChanged: (position, hasGesture) {
                _currentZoom = position.zoom ?? _currentZoom;
                _currentCenter = position.center;

                if (_currentCenter == null) {
                  if (_selectedGroom != null) {
                    setState(() {
                      _selectedGroom = null;
                    });
                  }
                  return;
                }

                final center = _currentCenter!;
                Map<String, dynamic>? nearestGroom;
                double nearestDistance = double.infinity;

                // Use filtered Grooms if searching, else all Grooms
                final GroomsToSearch = _searchText.isNotEmpty
                    ? _filteredGrooms
                    : grooms;

                for (var Groom in GroomsToSearch) {
                  final GroomLatLng = LatLng(Groom['lat'], Groom['lng']);
                  final distanceCalculator = Distance();
                  final distance = distanceCalculator(center, GroomLatLng);

                  if (distance < nearestDistance) {
                    nearestDistance = distance;
                    nearestGroom = Groom;
                  }
                }

                if (nearestGroom != null) {
                  if (_searchText.isNotEmpty) {
                    // Always show nearest Groom when searching
                    if (nearestGroom != _selectedGroom) {
                      setState(() {
                        _selectedGroom = nearestGroom;
                      });
                    }
                  } else {
                    // Only show Groom if zoomed in enough
                    if (_currentZoom >= 16.5) {
                      if (nearestGroom != _selectedGroom) {
                        setState(() {
                          _selectedGroom = nearestGroom;
                        });
                      }
                    } else {
                      // Zoomed out: hide sliding card
                      if (_selectedGroom != null) {
                        setState(() {
                          _selectedGroom = null;
                        });
                      }
                    }
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: grooms.map((run) {
                  final color = _markerColor(run);
                  return Marker(
                    point: LatLng(run['lat'], run['lng']),
                    width: 44,
                    height: 44,
                    child: Tooltip(
                      message: run['name'],
                      child: GestureDetector(
                        onTap: () {
                          if (_currentZoom >= 16.5) {
                            setState(() {
                              _selectedGroom = run;
                            });
                          } else {
                            // Zoom in first and store the target Groom
                            _zoomTargetGroom = run;
                            _mapController.move(
                              LatLng(run['lat'], run['lng']),
                              17,
                            );
                          }

                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(run['name']),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Address with copy
                                  if (run['address'] != null)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            run['address'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: run['address'],
                                              ),
                                            );
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Address copied!",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),

                                  // Show tel number
                                  if (run['tel'] != null)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Tel: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: SelectableText(run['tel']),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(text: run['tel']),
                                            );
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Phone number copied!",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _statusText(run),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_hoursLine(run)),
                                  const SizedBox(height: 8),
                                  if (run['rating'] != null)
                                    Text('Rating: ${run['rating']} ⭐'),
                                  const SizedBox(height: 12),
                                  if (run['mapUrl'] != null)
                                    InkWell(
                                      onTap: () async {
                                        final url = run['mapUrl'].toString();
                                        if (await canLaunchUrl(
                                          Uri.parse(url),
                                        )) {
                                          await launchUrl(
                                            Uri.parse(url),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            ctx,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not open Google Maps',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Open in Google Maps',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) => BookAppointmentPage(
                                            groomData: run,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Book Appointment'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(Icons.location_on, color: color, size: 40),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Sliding bottom card:
          if (_selectedGroom != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () async {
                  final url =
                      _selectedGroom!['mapUrl'] ??
                      'https://www.google.com/maps/search/?api=1&query=${_selectedGroom!['lat']},${_selectedGroom!['lng']}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedGroom!['name'] ?? 'Unknown Groom',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedGroom!['rating'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Rating: ${_selectedGroom!['rating']} ⭐'),
                        ),
                      if (_selectedGroom != null) ...[
                        Text(
                          _statusText(_selectedGroom!),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _markerColor(_selectedGroom!),
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                      if (_selectedGroom!['tel'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Tel: ${_selectedGroom!['tel']}'),
                        ),
                      SizedBox(height: 8),
                      Text(
                        'Tap here to open in Google Maps',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Legend at bottom right:
          Positioned(
            bottom: 20,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem(Colors.red, "Open"),
                  _legendItem(Colors.amber, "Closed"),
                  _legendItem(Colors.black, "Temporarily closed"),
                  _legendItem(Colors.blue, "Status unknown"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _legendItem(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.location_on, color: color, size: 20),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 13)),
    ],
  );
}
