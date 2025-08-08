import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // for Clipboard

class PetFriendlyMallsPage extends StatefulWidget {
  @override
  _PetFriendlyMallsPageState createState() => _PetFriendlyMallsPageState();
}

class _PetFriendlyMallsPageState extends State<PetFriendlyMallsPage> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  late MapController _mapController = MapController();
  String _searchText = '';
  List<Map<String, dynamic>> _selectedPetFriendlyMallss = [];
  late TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedPetFriendlyMalls;

  final List<Map<String, dynamic>> petfriendlymalls = [
    {
      'name': 'One Holland Village',
      'lat': 1.31163,
      'lng': 103.79364,
      'address': '7 Holland Vlg Wy, Singapore 275748',
      'rating': 4.5,
      'mapUrl': 'https://maps.app.goo.gl/8dMykQmSBBahyd448',
      'open': '11:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'The Star VIsta',
      'lat': 1.30705,
      'lng': 103.78845,
      'address': '1 Vista Exchange Green, Singapore 138617',
      'rating': 4.3,
      'mapUrl': 'https://maps.app.goo.gl/T7siLZL6yDhmUykN8',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'Great World',
      'lat': 1.29386,
      'lng': 103.83193,
      'address': '1 Kim Seng Promenade, Singapore 237994',
      'rating': 4.3,
      'mapUrl': 'https://maps.app.goo.gl/nA9ydeJHVtAPr4kBA',
      'open': '10:00',
      'close': '21:00',
      'tempClosed': false,
    },
    {
      'name': 'NEX',
      'lat': 1.35088,
      'lng': 103.87199,
      'address': 'Serangoon Central, 23, Singapore 556083',
      'rating': 4.3,
      'mapUrl': 'https://maps.app.goo.gl/kqyYtVB8s7JrNmJGA',
      'open': '10:30',
      'close': '22:30',
      'tempClosed': false,
    },
    {
      'name': 'PLQ Mall',
      'lat': 1.31787,
      'lng': 103.89311,
      'address': '10 Paya Lebar Rd, Singapore 409057',
      'rating': 4.4,
      'mapUrl': 'https://maps.app.goo.gl/cU3NoaqTccMLXbA4A',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'Tanglin Mall',
      'lat': 1.30511,
      'lng': 103.82336,
      'address': '163 Tanglin Rd, Singapore 247933',
      'rating': 4.2,
      'mapUrl': 'https://maps.app.goo.gl/AaCR4xjfUQzmUXsp7',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'Vivocity',
      'lat': 1.26494,
      'lng': 103.82320,
      'address': '1 HarbourFront Walk, Singapore 098585',
      'rating': 4.5,
      'mapUrl': 'https://maps.app.goo.gl/BpUhtqrBHnrEAWPp7',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'JEM',
      'lat': 1.33290,
      'lng': 103.74324,
      'address': '50 Jurong Gateway Rd, Singapore 608549',
      'rating': 4.3,
      'mapUrl': 'https://maps.app.goo.gl/RMxrcnGb3nzmqMfE7',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': 'Valley Point',
      'lat': 1.29340,
      'lng': 103.82718,
      'address': '491 River Valley Rd, Singapore 248371',
      'rating': 4,
      'mapUrl': 'https://maps.app.goo.gl/cuLv2PJ5kJZ3WYWL8',
      'open': '07:00',
      'close': '23:00',
      'tempClosed': false,
    },
    {
      'name': 'Waterway Point',
      'lat': 1.40668,
      'lng': 103.90213,
      'address': '83 Punggol Central, Singapore 828761',
      'rating': 4.4,
      'mapUrl': 'https://maps.app.goo.gl/DirN9Fw7x3X8q6XX7',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
    {
      'name': '313@somerset',
      'lat': 1.30124,
      'lng': 103.83867,
      'address': '313 Orchard Rd, Singapore 238895',
      'rating': 4.4,
      'mapUrl': 'https://maps.app.goo.gl/fA7VhpWTZHu8A3Eh8',
      'open': '10:00',
      'close': '22:00',
      'tempClosed': false,
    },
  ];

  double _currentZoom = 13.0;
  Map<String, dynamic>? _zoomTargetPetFriendlyMalls;

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

  Widget _buildPetFriendlyMallsDialog(
    BuildContext ctx,
    Map<String, dynamic> run,
  ) {
    final color = _markerColor(run);
    return AlertDialog(
      title: Text(run['name']),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (run['address'] != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    run['address'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: run['address']));
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text("Address copied!")),
                    );
                  },
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            _statusText(run),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(_hoursLine(run)),
          const SizedBox(height: 8),
          if (run['rating'] != null) Text('Rating: ${run['rating']} ⭐'),
          const SizedBox(height: 12),
          if (run['mapUrl'] != null)
            InkWell(
              onTap: () async {
                final url = run['mapUrl'].toString();
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Could not open Google Maps')),
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
    );
  }

  List<Map<String, dynamic>> get _filteredpetfriendlymalls {
    if (_searchText.isEmpty) {
      return petfriendlymalls;
    }
    return petfriendlymalls
        .where(
          (petfriendlymalls) => petfriendlymalls['name']
              .toString()
              .toLowerCase()
              .contains(_searchText.toLowerCase()),
        )
        .toList();
  }

  void _updateSelectedpetfriendlymalls(LatLng center) {
    const double maxDistanceMeters = 1000; // 1km radius for example
    setState(() {
      _selectedPetFriendlyMallss = _filteredpetfriendlymalls.where((
        petfriendlymall,
      ) {
        final petfriendlymallsLatLng = LatLng(
          petfriendlymall['lat'],
          petfriendlymall['lng'],
        );
        final Distance distanceCalculator = Distance();
        final distance = distanceCalculator(
          center,
          petfriendlymallsLatLng,
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
    _updateSelectedpetfriendlymalls(_currentCenter!);
    _searchController.addListener(() {
      final text = _searchController.text.toLowerCase();
      setState(() {
        _searchText = text;

        if (text.isEmpty) {
          _selectedPetFriendlyMalls = null;
          _showSuggestions = false;
          _suggestions = [];
        } else {
          _showSuggestions = true;
          _suggestions = petfriendlymalls.where((item) {
            final name = item['name'].toString().toLowerCase();
            return name.contains(text);
          }).toList();

          if (_currentCenter != null) {
            _updateSelectedpetfriendlymalls(_currentCenter!);
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
    for (var item in _filteredpetfriendlymalls) {
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
        _selectedPetFriendlyMalls = match;
      });
    } else {
      // Optionally show a message if no match found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No matching pet-friendly mall found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_bag_outlined, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Pet Friendly Malls in Singapore',
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
                    hintText: 'Search Pet-Friendly Malls by name...',
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
                  if (_selectedPetFriendlyMalls != null) {
                    setState(() {
                      _selectedPetFriendlyMalls = null;
                    });
                  }
                  return;
                }

                final center = _currentCenter!;
                Map<String, dynamic>? nearestPetFriendlyMalls;
                double nearestDistance = double.infinity;

                // Use filtered petfriendlymalls if searching, else all petfriendlymalls
                final petfriendlymallsToSearch = _searchText.isNotEmpty
                    ? _filteredpetfriendlymalls
                    : petfriendlymalls;

                for (var petfriendlymalls in petfriendlymallsToSearch) {
                  final petfriendlymallsLatLng = LatLng(
                    petfriendlymalls['lat'],
                    petfriendlymalls['lng'],
                  );
                  final distanceCalculator = Distance();
                  final distance = distanceCalculator(
                    center,
                    petfriendlymallsLatLng,
                  );

                  if (distance < nearestDistance) {
                    nearestDistance = distance;
                    nearestPetFriendlyMalls = petfriendlymalls;
                  }
                }

                if (nearestPetFriendlyMalls != null) {
                  if (_searchText.isNotEmpty) {
                    // Always show nearest PetFriendlyMalls when searching
                    if (nearestPetFriendlyMalls != _selectedPetFriendlyMalls) {
                      setState(() {
                        _selectedPetFriendlyMalls = nearestPetFriendlyMalls;
                      });
                    }
                  } else {
                    // Only show PetFriendlyMalls if zoomed in enough
                    if (_currentZoom >= 16.5) {
                      if (nearestPetFriendlyMalls !=
                          _selectedPetFriendlyMalls) {
                        setState(() {
                          _selectedPetFriendlyMalls = nearestPetFriendlyMalls;
                        });
                      }
                    } else {
                      // Zoomed out: hide sliding card
                      if (_selectedPetFriendlyMalls != null) {
                        setState(() {
                          _selectedPetFriendlyMalls = null;
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
                markers: petfriendlymalls.map((run) {
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
                              _selectedPetFriendlyMalls = run;
                            });
                          } else {
                            // Zoom in first and store the target PetFriendlyMalls
                            _zoomTargetPetFriendlyMalls = run;
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
          if (_selectedPetFriendlyMalls != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () async {
                  final url =
                      _selectedPetFriendlyMalls!['mapUrl'] ??
                      'https://www.google.com/maps/search/?api=1&query=${_selectedPetFriendlyMalls!['lat']},${_selectedPetFriendlyMalls!['lng']}';
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
                        _selectedPetFriendlyMalls!['name'] ??
                            'Unknown PetFriendlyMalls',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedPetFriendlyMalls!['rating'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Rating: ${_selectedPetFriendlyMalls!['rating']} ⭐',
                          ),
                        ),
                      if (_selectedPetFriendlyMalls != null) ...[
                        Text(
                          _statusText(_selectedPetFriendlyMalls!),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _markerColor(_selectedPetFriendlyMalls!),
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                      if (_selectedPetFriendlyMalls!['tel'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Tel: ${_selectedPetFriendlyMalls!['tel']}',
                          ),
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
