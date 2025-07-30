import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import '../../ChatScreen.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialFocus;
  final String? initialPlaceName;
  final List<Map<String, dynamic>>? customPlaces;
  const MapPage({
    super.key,
    this.initialFocus,
    this.initialPlaceName,
    this.customPlaces,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _userLocation;
  Attraction? _selectedAttraction;
  Landmark? _selectedLandmark;
  bool _loading = false;
  List<LatLng> _route = [];
  String _searchQuery = '';
  bool _showNearest = false;
  double _nearestRadius = 3.0;
  bool _liveLocation = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _liveLocationTimer;
  MapController _mapController = MapController();

  @override
  void dispose() {
    _liveLocationTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    if (widget.customPlaces != null && widget.customPlaces!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusOnCustomPlaces();
      });
    } else if (widget.initialPlaceName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusOnPlaceByName(widget.initialPlaceName!);
      });
    } else if (widget.initialFocus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.initialFocus!, 15);
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Enable GPS to use location features'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Location permission needed for full features'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Silent fail for permission check
    }
  }

  Future<void> _getUserLocation({bool animate = false}) async {
    setState(() {
      _loading = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError(
          'Location services are disabled. Please enable GPS in your device settings.',
        );
        return;
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError(
            'Location permission denied. Please enable location access in app settings.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError(
          'Location permission permanently denied. Please enable location access in app settings.',
        );
        return;
      }

      // Get current position with timeout
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
      });

      if (animate) {
        _mapController.move(_userLocation!, 15);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📍 Location found: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      String errorMessage = 'Failed to get location. Please try again.';

      if (e.toString().contains('timeout')) {
        errorMessage =
            'Location request timed out. Please check your GPS signal and try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      _showLocationError(errorMessage);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            // Open app settings
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
  }

  void _toggleLiveLocation() {
    setState(() {
      _liveLocation = !_liveLocation;
    });
    if (_liveLocation) {
      _liveLocationTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _getUserLocation(animate: true),
      );
    } else {
      _liveLocationTimer?.cancel();
    }
  }

  void _focusOnPlaceByName(String name) {
    final foundA = attractions.firstWhereOrNull((a) => a.name == name);
    final foundL = allLandmarks.firstWhereOrNull((l) => l.name == name);
    if (foundA != null) {
      setState(() {
        _selectedAttraction = foundA;
        _selectedLandmark = null;
        _drawRouteTo(LatLng(foundA.lat, foundA.lng));
      });
      _mapController.move(LatLng(foundA.lat, foundA.lng), 15);
    } else if (foundL != null) {
      setState(() {
        _selectedLandmark = foundL;
        _selectedAttraction = null;
        _drawRouteTo(LatLng(foundL.lat, foundL.lng));
      });
      _mapController.move(LatLng(foundL.lat, foundL.lng), 15);
    }
  }

  List<Attraction> get _filteredAttractions {
    final query = _searchQuery.toLowerCase();
    List<Attraction> filtered =
        attractions
            .where(
              (a) =>
                  a.name.toLowerCase().contains(query) ||
                  a.description.toLowerCase().contains(query),
            )
            .toList();
    if (_showNearest && _userLocation != null) {
      filtered =
          filtered
              .where(
                (a) =>
                    _distanceInKm(
                      _userLocation!.latitude,
                      _userLocation!.longitude,
                      a.lat,
                      a.lng,
                    ) <=
                    _nearestRadius,
              )
              .toList();
    }
    return filtered;
  }

  List<Landmark> get _filteredLandmarks {
    final query = _searchQuery.toLowerCase();
    List<Landmark> filtered =
        allLandmarks
            .where(
              (l) =>
                  l.name.toLowerCase().contains(query) ||
                  l.description.toLowerCase().contains(query),
            )
            .toList();
    if (_showNearest && _userLocation != null) {
      filtered =
          filtered
              .where(
                (l) =>
                    _distanceInKm(
                      _userLocation!.latitude,
                      _userLocation!.longitude,
                      l.lat,
                      l.lng,
                    ) <=
                    _nearestRadius,
              )
              .toList();
    }
    return filtered;
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // If customPlaces is set, ONLY show those
    if (widget.customPlaces != null && widget.customPlaces!.isNotEmpty) {
      for (final place in widget.customPlaces!) {
        markers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(place['lat'], place['lng']),
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: const Icon(
                  Icons.restaurant,
                  color: Colors.orange,
                  size: 32,
                ),
                onPressed: () {
                  _showCustomPlaceDetails(place);
                },
              ),
            ),
          ),
        );
      }
      return markers;
    }

    for (final a in _filteredAttractions) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(a.lat, a.lng),
          child: AnimatedScale(
            scale: _selectedAttraction == a ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(Icons.place, color: Colors.indigo, size: 32),
              onPressed: () {
                setState(() {
                  _selectedAttraction = a;
                  _selectedLandmark = null;
                  _drawRouteTo(LatLng(a.lat, a.lng));
                });
                _mapController.move(LatLng(a.lat, a.lng), 15);
              },
            ),
          ),
        ),
      );
    }
    for (final l in _filteredLandmarks) {
      markers.add(
        Marker(
          width: 36,
          height: 36,
          point: LatLng(l.lat, l.lng),
          child: AnimatedScale(
            scale: _selectedLandmark == l ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(Icons.star, color: Colors.amber, size: 28),
              onPressed: () {
                setState(() {
                  _selectedLandmark = l;
                  _selectedAttraction = null;
                  _drawRouteTo(LatLng(l.lat, l.lng));
                });
                _mapController.move(LatLng(l.lat, l.lng), 15);
              },
            ),
          ),
        ),
      );
    }
    if (_userLocation != null) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: _userLocation!,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.person_pin_circle,
                color: Colors.green,
                size: 36,
              ),
              if (_liveLocation)
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return markers;
  }

  void _drawRouteTo(LatLng dest) {
    if (_userLocation == null) {
      setState(() => _route = []);
      return;
    }
    // For demo: just a straight line. For real routing, use an API.
    setState(() {
      _route = [_userLocation!, dest];
    });
  }

  void _clearRoute() {
    setState(() => _route = []);
  }

  void _focusOnCustomPlaces() {
    if (widget.customPlaces != null && widget.customPlaces!.isNotEmpty) {
      // Calculate center point of all custom places
      double totalLat = 0;
      double totalLng = 0;
      for (final place in widget.customPlaces!) {
        totalLat += place['lat'];
        totalLng += place['lng'];
      }
      final centerLat = totalLat / widget.customPlaces!.length;
      final centerLng = totalLng / widget.customPlaces!.length;

      // Move map to center of all places with appropriate zoom
      _mapController.move(LatLng(centerLat, centerLng), 12);
    }
  }

  void _showCustomPlaceDetails(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Color(0xFFF59E0B),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place['name'],
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              place['type'],
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '📍 ${place['address']}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      onPressed: () {
                        Navigator.pop(context);
                        if (_userLocation != null) {
                          _drawRouteTo(LatLng(place['lat'], place['lng']));
                          _mapController.move(
                            LatLng(place['lat'], place['lng']),
                            15,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  double _distanceInKm(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371; // Earth radius in km
    double dLat = (lat2 - lat1) * 3.141592653589793 / 180;
    double dLng = (lng2 - lng1) * 3.141592653589793 / 180;
    double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * 3.141592653589793 / 180) *
            cos(lat2 * 3.141592653589793 / 180) *
            (sin(dLng / 2) * sin(dLng / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    final center = _userLocation ?? LatLng(52.5163, 13.3777);
    // Auto-focus if search yields a single result
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchQuery.isNotEmpty) {
        final allResults = [..._filteredAttractions, ..._filteredLandmarks];
        if (allResults.length == 1) {
          final place = allResults.first;
          LatLng pos =
              place is Attraction
                  ? LatLng(place.lat, place.lng)
                  : LatLng((place as Landmark).lat, (place as Landmark).lng);
          _mapController.move(pos, 15);
          if (place is Attraction) {
            setState(() {
              _selectedAttraction = place;
              _selectedLandmark = null;
              _drawRouteTo(pos);
            });
          } else if (place is Landmark) {
            setState(() {
              _selectedLandmark = place;
              _selectedAttraction = null;
              _drawRouteTo(pos);
            });
          }
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berlin Map Explorer'),
        actions: [
          if (_userLocation != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Located',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search attractions or landmarks...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<double>(
                  icon: const Icon(Icons.filter_alt),
                  onSelected:
                      (val) => setState(() {
                        _showNearest = val < 100;
                        _nearestRadius = val;
                      }),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 3.0,
                          child: Text('Within 3 km'),
                        ),
                        const PopupMenuItem(
                          value: 5.0,
                          child: Text('Within 5 km'),
                        ),
                        const PopupMenuItem(
                          value: 100.0,
                          child: Text('Show All'),
                        ),
                      ],
                ),
                IconButton(
                  icon: Icon(
                    _liveLocation ? Icons.gps_fixed : Icons.gps_not_fixed,
                  ),
                  tooltip: 'Live Location',
                  onPressed: _toggleLiveLocation,
                ),
                IconButton(
                  icon:
                      _loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          )
                          : Icon(
                            _userLocation != null
                                ? Icons.my_location
                                : Icons.location_searching,
                            color:
                                _userLocation != null
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                  tooltip:
                      _userLocation != null
                          ? 'Center on My Location'
                          : 'Get My Location',
                  onPressed:
                      _loading ? null : () => _getUserLocation(animate: true),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(maxZoom: 18, minZoom: 10),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    PolylineLayer(
                      polylines:
                          _route.isNotEmpty
                              ? <Polyline<LatLng>>[
                                Polyline<LatLng>(
                                  points: _route,
                                  color: Colors.indigo,
                                  strokeWidth: 5,
                                ),
                              ]
                              : <Polyline<LatLng>>[],
                    ),
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ),
                if (_loading) const Center(child: CircularProgressIndicator()),
                if (_selectedAttraction != null)
                  _buildAttractionPopup(_selectedAttraction!),
                if (_selectedLandmark != null)
                  _buildLandmarkPopup(_selectedLandmark!),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon:
            _loading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Icon(
                  _userLocation != null
                      ? Icons.my_location
                      : Icons.location_searching,
                  color: _userLocation != null ? Colors.white : Colors.orange,
                ),
        label: Text(_loading ? 'Getting Location...' : 'My Location'),
        backgroundColor:
            _userLocation != null ? const Color(0xFF1E3A8A) : Colors.orange,
        onPressed: _loading ? null : () => _getUserLocation(animate: true),
      ),
    );
  }

  Widget _buildAttractionPopup(Attraction attraction) {
    return _buildPopup(
      title: attraction.name,
      description: attraction.description,
      note: attraction.note,
      onClose: () {
        setState(() {
          _selectedAttraction = null;
          _clearRoute();
        });
      },
    );
  }

  Widget _buildLandmarkPopup(Landmark landmark) {
    return _buildPopup(
      title: landmark.name,
      description: landmark.description,
      onClose: () {
        setState(() {
          _selectedLandmark = null;
          _clearRoute();
        });
      },
    );
  }

  Widget _buildPopup({
    required String title,
    required String description,
    String? note,
    required VoidCallback onClose,
  }) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 16)),
                  if (note != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Note: $note',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                  if (_userLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: const Text('Show Route'),
                        onPressed: () {
                          // Redirect to chat with Gemini for best route
                          final userLoc = _userLocation;
                          if (userLoc != null) {
                            final prompt =
                                'What is the best way to go from my location (${userLoc.latitude}, ${userLoc.longitude}) to $title in Berlin? Suggest public transport or walking.';
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ChatScreen(initialMessage: prompt),
                              ),
                            );
                          }
                        },
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
}

// Add the Attraction and Landmark classes and data from the provided code
class Attraction {
  final String name;
  final String description;
  final double lat;
  final double lng;
  final String note;
  Attraction({
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.note,
  });
}

class Landmark {
  final String name;
  final String description;
  final double lat;
  final double lng;
  Landmark({
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
  });
}

List<Attraction> attractions = [
  Attraction(
    name: 'Brandenburg Gate',
    description: 'Iconic 18th-century neoclassical monument.',
    lat: 52.5163,
    lng: 13.3777,
    note: 'A symbol of Berlin.',
  ),
  Attraction(
    name: 'Museum Island',
    description: 'UNESCO World Heritage site with 5 museums.',
    lat: 52.5169,
    lng: 13.4010,
    note: 'Great for art and history lovers.',
  ),
  Attraction(
    name: 'Berlin Cathedral',
    description: 'Impressive baroque-style Protestant cathedral.',
    lat: 52.5192,
    lng: 13.4010,
    note: 'Climb the dome for a view!',
  ),
  Attraction(
    name: 'East Side Gallery',
    description: 'Famous open-air Berlin Wall gallery.',
    lat: 52.5050,
    lng: 13.4394,
    note: 'See the murals.',
  ),
  Attraction(
    name: 'Checkpoint Charlie',
    description: 'Historic Cold War border crossing.',
    lat: 52.5076,
    lng: 13.3904,
    note: 'Photo spot!',
  ),
  Attraction(
    name: 'Gendarmenmarkt',
    description: 'Beautiful square with concert hall and cathedrals.',
    lat: 52.5138,
    lng: 13.3926,
    note: 'Lovely at sunset.',
  ),
  Attraction(
    name: 'Charlottenburg Palace',
    description: 'Baroque palace with gardens.',
    lat: 52.5208,
    lng: 13.2956,
    note: 'Stroll the gardens.',
  ),
  Attraction(
    name: 'Tempelhofer Feld',
    description: 'Former airport, now a huge urban park.',
    lat: 52.4730,
    lng: 13.4036,
    note: 'Picnic or cycle!',
  ),
  Attraction(
    name: 'Kreuzberg Street Art',
    description: 'Trendy area with murals and cafes.',
    lat: 52.4996,
    lng: 13.4033,
    note: 'Street art everywhere.',
  ),
  Attraction(
    name: 'Tiergarten Park',
    description: 'Large central park, great for walks.',
    lat: 52.5145,
    lng: 13.3501,
    note: 'Relax in nature.',
  ),
  Attraction(
    name: 'Potsdamer Platz',
    description: 'Modern plaza with shops and history.',
    lat: 52.5096,
    lng: 13.3750,
    note: 'Urban Berlin.',
  ),
  Attraction(
    name: 'Victory Column',
    description: 'Famous monument in Tiergarten.',
    lat: 52.5145,
    lng: 13.3501,
    note: 'Climb for a view!',
  ),
  Attraction(
    name: 'Berlin Zoo',
    description: 'One of the world\'s most famous zoos.',
    lat: 52.5080,
    lng: 13.3370,
    note: 'Great for families.',
  ),
  Attraction(
    name: 'Hackescher Markt',
    description: 'Trendy area with shops and nightlife.',
    lat: 52.5246,
    lng: 13.4026,
    note: 'Nightlife and food.',
  ),
  Attraction(
    name: 'Prenzlauer Berg',
    description: 'Hip neighborhood with cafes and parks.',
    lat: 52.5380,
    lng: 13.4244,
    note: 'Brunch and strolls.',
  ),
  Attraction(
    name: 'Olympic Stadium',
    description: 'Historic sports stadium.',
    lat: 52.5147,
    lng: 13.2394,
    note: 'Sports and concerts.',
  ),
];

List<Landmark> allLandmarks = [
  Landmark(
    name: 'Reichstag Building',
    description: 'German Parliament with glass dome.',
    lat: 52.5186,
    lng: 13.3761,
  ),
  Landmark(
    name: 'Alexanderplatz',
    description: 'Major square with TV tower.',
    lat: 52.5219,
    lng: 13.4132,
  ),
  Landmark(
    name: 'Kurfürstendamm',
    description: 'Famous shopping boulevard.',
    lat: 52.5049,
    lng: 13.3276,
  ),
];
