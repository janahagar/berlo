import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../recommendations/recommendations_page.dart';
import '../mini_tours/mini_tours_page.dart';
import 'package:collection/collection.dart';
import '../../ChatScreen.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialFocus;
  final String? initialPlaceName;
  const MapPage({super.key, this.initialFocus, this.initialPlaceName});

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
    _getUserLocation();
    if (widget.initialPlaceName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusOnPlaceByName(widget.initialPlaceName!);
      });
    } else if (widget.initialFocus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.initialFocus!, 15);
      });
    }
  }

  Future<void> _getUserLocation({bool animate = false}) async {
    setState(() {
      _loading = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
      });
      if (animate) {
        _mapController.move(_userLocation!, 15);
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
      appBar: AppBar(title: const Text('Berlin Map Explorer')),
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
                  icon: const Icon(Icons.my_location),
                  tooltip: 'Center on Me',
                  onPressed: () => _getUserLocation(animate: true),
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
        icon: const Icon(Icons.my_location),
        label: const Text('My Location'),
        onPressed: () => _getUserLocation(animate: true),
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
