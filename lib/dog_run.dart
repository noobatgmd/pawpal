import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // for Clipboard

class DogRunsMapPage extends StatefulWidget {
  @override
  _DogRunsMapPageState createState() => _DogRunsMapPageState();
}

class _DogRunsMapPageState extends State<DogRunsMapPage> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  late MapController _mapController = MapController();
  String _searchText = '';
  late TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedDogRun;

  final List<Map<String, dynamic>> dogruns = [
    {
      'name': 'Bishan-Ang Mo Kio Park Dog Run',
      'lat': 1.3626187436951578,
      'lng': 103.84855965216472,
      'address': 'Bishan-Ang Mo Kio Park, Bishan Ave 1, Singapore 569972',
      'rating': 4.5,
      'mapUrl': 'https://maps.app.goo.gl/tXEP2nZ6kJrwN7EJ6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'East Coast Park Dog Run',
      'lat': 1.2996115984557481,
      'lng': 103.90763255586226,
      'address': 'East Coast Park, Parkland Green, Singapore 449875',
      'rating': 4.5,
      'mapUrl': 'https://maps.app.goo.gl/p7yHDuifTfKLM8bC8',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Sengkang Riverside Park Dog Run',
      'lat': 1.3973312653936967,
      'lng': 103.8828399810002,
      'address': 'Sengkang Riverside Park, Sengkang East Ave, Singapore',
      'rating': 3.5,
      'mapUrl': 'https://maps.app.goo.gl/UY1fS2W4WqMCPP4b9',
      'open': '07:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Clementi Woods Park Dog Run',
      'lat': 1.3032138690996098,
      'lng': 103.76685114907563,
      'address': 'Clementi Woods Park, Clementi Ave 6, Singapore',
      'rating': 4.3,
      'mapUrl': 'https://maps.app.goo.gl/RMNWwvhSg4sgwTNf6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Jurong Lake Gardens Dog Run',
      'lat': 1.3347490336492185,
      'lng': 103.7264049134704,
      'address': 'Jurong Lake Gardens, Yuan Ching Rd, Singapore',
      'rating': 4.5,
      'mapUrl': 'https://maps.app.goo.gl/ssWD4jSVBNZ4H8hy7',
      'open': '08:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'Mayfair Park Dog Run',
      'lat': 1.3417033424316684,
      'lng': 103.78076632278818,
      'address': 'Mayfair Park, Jalan Gaharu, Bukit Timah, Singapore',
      'rating': 4.4,
      'mapUrl': 'https://maps.app.goo.gl/67Pwt6DbRHrUC4756',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Sembawang Park Dog Run',
      'lat': 1.4619161681772657,
      'lng': 103.83645116081567,
      'address': 'Sembawang Park, Sembawang Rd, Singapore',
      'rating': 4.6,
      'mapUrl': 'https://maps.app.goo.gl/wq6WVM7FRt9UzWR59',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Yishun Park Dog Run',
      'lat': 1.426832637953284,
      'lng': 103.84125401503604,
      'address': 'Yishun Park, Yishun Ave 11, Singapore',
      'rating': 4.2,
      'mapUrl': 'https://maps.app.goo.gl/sgKKAEWsivRLhic77',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Woodlands Waterfront Dog Run',
      'lat': 1.4524031197043452,
      'lng': 103.77974424417764,
      'address': 'Woodlands Waterfront Dog Run, Woodlands Waterfront Park',
      'rating': 4.4,
      'mapUrl': 'https://maps.app.goo.gl/yztTJHNqHZ2cbatW8',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Bukit Canberra Dog Run',
      'lat': 1.44700679357528,
      'lng': 103.82448654068246,
      'address': '21 Canberra Link, Bukit Canberra Dog Run, Singapore 752106',
      'rating': 5,
      'mapUrl': 'https://maps.app.goo.gl/9tjjytN6urhG3rWq5',
      'open': '07:00',
      'close': '23:00',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Punggol Waterway Park',
      'lat': 1.4121352720342497,
      'lng': 103.90194230184866,
      'address':
          'Dog Run @ Punggol Waterway Park, Punggol waterway park, Singapore 821313',
      'rating': 4.1,
      'mapUrl': 'https://maps.app.goo.gl/hNm2rdZC8gV44sxK9',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Mariam Way Dog Run',
      'lat': 1.362285075762702,
      'lng': 103.96601401349344,
      'address': '377 Old Tampines Rd, Mariam Way Dog Run',
      'rating': 4.1,
      'mapUrl': 'https://maps.app.goo.gl/boNgsutr4Jm6hWhH7',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Opera Estate',
      'lat': 1.3200614788159748,
      'lng': 103.9242810306842,
      'address': 'Swan Lake Ave, Dog Run @ Opera Estate',
      'rating': 5,
      'mapUrl': 'https://maps.app.goo.gl/Jc19epf81WLseMcK8',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run at Kembangan',
      'lat': 1.327826382084599,
      'lng': 103.91499891534207,
      'address': 'Lengkong Enam, Dog Run at Kembangan',
      'rating': 4.2,
      'mapUrl': 'https://maps.app.goo.gl/QXejwj3HBJ6BJuRC6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Koon Seng Park',
      'lat': 1.3110716835654668,
      'lng': 103.90336387671049,
      'address': '36 Koon Seng Rd, Singapore 426978',
      'rating': 4.1,
      'mapUrl': 'https://maps.app.goo.gl/A7Cp57p27L1CWSYJ6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Sin Ming',
      'lat': 1.3584620216263514,
      'lng': 103.83266525216487,
      'address': 'Dog Run @ Sin Ming',
      'rating': 3,
      'mapUrl': 'https://maps.app.goo.gl/sKFsPXfanTwMTUd66',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog run at Teck Ghee Neighbourhood 4 Park',
      'lat': 1.368041552674764,
      'lng': 103.86033775896699,
      'address': 'Ang Mo Kio Ave 10, Teck Ghee Neighbourhood 4 Park',
      'rating': 'N.A.',
      'mapUrl': 'https://maps.app.goo.gl/7ivfcb4rQa66s8U78',
    },
    {
      'name': 'Surin Park Dog Run',
      'lat': 1.3551857603332482,
      'lng': 103.88383032517801,
      'address': 'Surin Ave, Neighbourhood Park',
      'rating': 4.9,
      'mapUrl': 'https://maps.app.goo.gl/4C2y4JDvbNgx5nLY6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog run @ Tai Gin',
      'lat': 1.3288365459437217,
      'lng': 103.84637699294356,
      'address': '16 Tai Gin Rd',
      'rating': 4.3,
      'mapUrl': 'https://maps.app.goo.gl/KMbttzfoKfrmWK9j6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Mount Emily Park Dog Run',
      'lat': 1.305053605931672,
      'lng': 103.84867350554602,
      'address': '11 Mount Emily Rd, Singapore 228493',
      'rating': 4.2,
      'mapUrl': 'https://maps.app.goo.gl/V1j15rCafVwfZh5WA',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Tiong Bahru Sit Wah Dog Run',
      'lat': 1.2829264121581214,
      'lng': 103.83333558465789,
      'address': 'Behind 82 Tiong Poh Road, Sit Wah Rd, Enter by, 160082',
      'rating': 3.4,
      'mapUrl': 'https://maps.app.goo.gl/5FmcBJh4Mrd8MZiq9',
      'open': '07:00',
      'close': '19:00',
      'tempClosed': false,
    },
    {
      'name': 'Bukit Gombak Park Dog Run',
      'lat': 1.3678328657615575,
      'lng': 103.75314780593776,
      'address': 'Bukit Batok West Ave. 5',
      'rating': 3.8,
      'mapUrl': 'https://maps.app.goo.gl/qoJ4NxYVoW9vupcP6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'The Palawan Dog Run',
      'lat': 1.2507747029087606,
      'lng': 103.81986428006981,
      'address': '54 Palawan Beach Walk, The Palawan @ Sentosa, 098233',
      'rating': 3.7,
      'mapUrl': 'https://maps.app.goo.gl/Vuu2jAdL3ijJtap88',
      'open': '09:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Tiong Bahru Park',
      'lat': 1.2890213583719048,
      'lng': 103.82329774598644,
      'address': '1 Henderson Rd, Singapore 159561',
      'rating': 4,
      'mapUrl': 'https://maps.app.goo.gl/arKrwFjyQkNAESh17',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Ang Mo Kio Town Garden West Dog Run',
      'lat': 1.3729590652513812,
      'lng': 103.8438245734048,
      'address': '10 Ang Mo Kio Street 12, Singapore 567740',
      'rating': 4.6,
      'mapUrl': 'https://maps.app.goo.gl/ZJhrt13eCTKMybDp8',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog Park at Upp Serangoon 21 (Potong Pasir Avenue 1 Dog Run)',
      'lat': 1.3333547144183668,
      'lng': 103.86931124650839,
      'address': '120 Upper Serangoon Rd, Singapore 347685',
      'rating': 4.4,
      'mapUrl': 'https://maps.app.goo.gl/1GRuhwVfP54zFwHi8',
      'open': '05:00',
      'close': '21:45',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Punggol Park',
      'lat': 1.3788550781840185,
      'lng': 103.90059320389129,
      'address': 'Pungol Park, 471B Upper Serangoon Cres, Singapore 532471',
      'rating': 2.6,
      'mapUrl': 'https://maps.app.goo.gl/fCFFF8f2FYtiayUc6',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Sun Plaza Park',
      'lat': 1.3586779675985632,
      'lng': 103.94326366806538,
      'address': 'Sun Plaza Park, Tampines Ave 7',
      'rating': 3,
      'mapUrl': 'https://maps.app.goo.gl/JCEZ7V76twL4WQnv7',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Tampines Central Park',
      'lat': 1.3542854777188318,
      'lng': 103.93957090688568,
      'address': 'Blk 856 Tampines Street 82, Singapore 520856',
      'rating': 4.2,
      'mapUrl': 'https://maps.app.goo.gl/zoquvHQdEMFU3MJa8',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'KP Dog Run',
      'lat': 1.2981666921271406,
      'lng': 103.88983284818885,
      'address': 'Katong Park, 59 Fort Rd, Singapore 439105',
      'rating': 3.3,
      'mapUrl': 'https://maps.app.goo.gl/YGHEtv3A9aS4uQma7',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'Dog Run @ Pasir Ris Park',
      'lat': 1.3870399722219928,
      'lng': 103.94201986001161,
      'address': '125 Pasir Ris Rd, Singapore 519121',
      'rating': 3.9,
      'mapUrl': 'https://maps.app.goo.gl/u7h9FMsXmUFq4bra8',
      'open': '24H',
      'close': '24H',
      'tempClosed': false,
    },
    {
      'name': 'West Coast Park Dog Run',
      'lat': 1.2877790241121339,
      'lng': 103.77475311499764,
      'address': 'West Coast Park, Parallel to West Coast Highway',
      'rating': 4.5,
      'mapUrl': 'https://maps.app.goo.gl/CEAXspjyHNYZ8SbbA',
      'open': '24H',
      'close': '24H',
      'tempClosed': true,
    },
    {
      'name': 'Telok Kurau Dog Run',
      'lat': 1.3152474888155221,
      'lng': 103.91332629909505,
      'address': 'Telok Kurau Park 151 Lorong J Telok Kurau, Singapore 423466',
      'rating': 4.5,
      'mapUrl': 'https://maps.app.goo.gl/JSge3E2PxF5Rm9618',
      'open': '24H',
      'close': '24H',
      'tempClosed': true,
    },
  ];

  double _currentZoom = 13.0;

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

  List<Map<String, dynamic>> get _filtereddogruns {
    if (_searchText.isEmpty) {
      return dogruns;
    }
    return dogruns
        .where(
          (dogrun) => dogrun['name'].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          ),
        )
        .toList();
  }

  void _updateSelecteddogruns(LatLng center) {
    setState(() {});
  }

  LatLng? _currentCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _currentCenter = const LatLng(1.3521, 103.8198);
    _updateSelecteddogruns(_currentCenter!);
    _searchController.addListener(() {
      final text = _searchController.text.toLowerCase();
      setState(() {
        _searchText = text;

        if (text.isEmpty) {
          _selectedDogRun = null;
          _showSuggestions = false;
          _suggestions = [];
        } else {
          _showSuggestions = true;
          _suggestions = dogruns.where((item) {
            final name = item['name'].toString().toLowerCase();
            return name.contains(text);
          }).toList();

          if (_currentCenter != null) {
            _updateSelecteddogruns(_currentCenter!);
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
    for (var item in _filtereddogruns) {
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
        _selectedDogRun = match;
      });
    } else {
      // Optionally show a message if no match found
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No matching Dog Runs found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.run_circle_outlined, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Dog Runs in Singapore',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
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
                    hintText: 'Search Dog Runs by name...',
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
                _currentZoom = position.zoom;
                _currentCenter = position.center;

                if (_currentCenter == null) {
                  if (_selectedDogRun != null) {
                    setState(() {
                      _selectedDogRun = null;
                    });
                  }
                  return;
                }

                final center = _currentCenter!;
                Map<String, dynamic>? nearestDogRun;
                double nearestDistance = double.infinity;

                // Use filtered dogruns if searching, else all dogruns
                final dogrunsToSearch = _searchText.isNotEmpty
                    ? _filtereddogruns
                    : dogruns;

                for (var DogRun in dogrunsToSearch) {
                  final DogRunLatLng = LatLng(DogRun['lat'], DogRun['lng']);
                  final distanceCalculator = Distance();
                  final distance = distanceCalculator(center, DogRunLatLng);

                  if (distance < nearestDistance) {
                    nearestDistance = distance;
                    nearestDogRun = DogRun;
                  }
                }

                if (nearestDogRun != null) {
                  if (_searchText.isNotEmpty) {
                    // Always show nearest DogRun when searching
                    if (nearestDogRun != _selectedDogRun) {
                      setState(() {
                        _selectedDogRun = nearestDogRun;
                      });
                    }
                  } else {
                    // Only show DogRun if zoomed in enough
                    if (_currentZoom >= 16.5) {
                      if (nearestDogRun != _selectedDogRun) {
                        setState(() {
                          _selectedDogRun = nearestDogRun;
                        });
                      }
                    } else {
                      // Zoomed out: hide sliding card
                      if (_selectedDogRun != null) {
                        setState(() {
                          _selectedDogRun = null;
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
                markers: dogruns.map((run) {
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
                              _selectedDogRun = run;
                            });
                          } else {
                            // Zoom in first and store the target DogRun
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
          if (_selectedDogRun != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () async {
                  final url =
                      _selectedDogRun!['mapUrl'] ??
                      'https://www.google.com/maps/search/?api=1&query=${_selectedDogRun!['lat']},${_selectedDogRun!['lng']}';
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
                        _selectedDogRun!['name'] ?? 'Unknown DogRun',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedDogRun!['rating'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Rating: ${_selectedDogRun!['rating']} ⭐',
                          ),
                        ),
                      if (_selectedDogRun != null) ...[
                        Text(
                          _statusText(_selectedDogRun!),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _markerColor(_selectedDogRun!),
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                      if (_selectedDogRun!['tel'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Tel: ${_selectedDogRun!['tel']}'),
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
