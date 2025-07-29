import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:flutter/animation.dart';
import '../map/map_page.dart';

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

class MiniTour {
  final String name;
  final String description;
  final List<Landmark> stops;
  MiniTour({
    required this.name,
    required this.description,
    required this.stops,
  });
}

final List<Landmark> allLandmarks = [
  Landmark(
    name: 'Brandenburg Gate',
    description: 'Iconic 18th-century neoclassical monument.',
    lat: 52.5163,
    lng: 13.3777,
  ),
  Landmark(
    name: 'Museum Island',
    description: 'UNESCO World Heritage site with 5 museums.',
    lat: 52.5169,
    lng: 13.4010,
  ),
  Landmark(
    name: 'Berlin Cathedral',
    description: 'Impressive baroque-style Protestant cathedral.',
    lat: 52.5192,
    lng: 13.4010,
  ),
  Landmark(
    name: 'East Side Gallery',
    description: 'Famous open-air Berlin Wall gallery.',
    lat: 52.5050,
    lng: 13.4394,
  ),
  Landmark(
    name: 'Checkpoint Charlie',
    description: 'Historic Cold War border crossing.',
    lat: 52.5076,
    lng: 13.3904,
  ),
  Landmark(
    name: 'Gendarmenmarkt',
    description: 'Beautiful square with concert hall and cathedrals.',
    lat: 52.5138,
    lng: 13.3926,
  ),
  Landmark(
    name: 'Charlottenburg Palace',
    description: 'Baroque palace with gardens.',
    lat: 52.5208,
    lng: 13.2956,
  ),
  Landmark(
    name: 'Tempelhofer Feld',
    description: 'Former airport, now a huge urban park.',
    lat: 52.4730,
    lng: 13.4036,
  ),
  Landmark(
    name: 'Kreuzberg Street Art',
    description: 'Trendy area with murals and cafes.',
    lat: 52.4996,
    lng: 13.4033,
  ),
  Landmark(
    name: 'Tiergarten Park',
    description: 'Large central park, great for walks.',
    lat: 52.5145,
    lng: 13.3501,
  ),
  Landmark(
    name: 'Potsdamer Platz',
    description: 'Modern plaza with shops and history.',
    lat: 52.5096,
    lng: 13.3750,
  ),
  Landmark(
    name: 'Victory Column',
    description: 'Famous monument in Tiergarten.',
    lat: 52.5145,
    lng: 13.3501,
  ),
  Landmark(
    name: 'Berlin Zoo',
    description: 'One of the world’s most famous zoos.',
    lat: 52.5080,
    lng: 13.3370,
  ),
  Landmark(
    name: 'Hackescher Markt',
    description: 'Trendy area with shops and nightlife.',
    lat: 52.5246,
    lng: 13.4026,
  ),
  Landmark(
    name: 'Prenzlauer Berg',
    description: 'Hip neighborhood with cafes and parks.',
    lat: 52.5380,
    lng: 13.4244,
  ),
  Landmark(
    name: 'Olympic Stadium',
    description: 'Historic sports stadium.',
    lat: 52.5147,
    lng: 13.2394,
  ),
];

final List<MiniTour> miniTours = [
  MiniTour(
    name: 'Berlin Classics',
    description: 'See the most iconic Berlin sights in one go.',
    stops: [allLandmarks[0], allLandmarks[1], allLandmarks[2]],
  ),
  MiniTour(
    name: 'Wall & Cold War',
    description: 'Explore Berlin Wall history and Cold War sites.',
    stops: [allLandmarks[3], allLandmarks[4], allLandmarks[5]],
  ),
  MiniTour(
    name: 'Royal Berlin',
    description: 'Palaces, gardens, and royal history.',
    stops: [allLandmarks[6], allLandmarks[9], allLandmarks[0]],
  ),
  MiniTour(
    name: 'Trendy Kreuzberg',
    description: 'Street art, cafes, and urban vibes.',
    stops: [allLandmarks[8], allLandmarks[3], allLandmarks[7]],
  ),
  MiniTour(
    name: 'Modern Berlin',
    description: 'Experience Berlin’s modern side.',
    stops: [allLandmarks[10], allLandmarks[12], allLandmarks[13]],
  ),
  MiniTour(
    name: 'Family Day',
    description: 'Fun for all ages in Berlin.',
    stops: [allLandmarks[12], allLandmarks[11], allLandmarks[14]],
  ),
  MiniTour(
    name: 'Hipster Berlin',
    description: 'Cafes, parks, and nightlife.',
    stops: [allLandmarks[13], allLandmarks[14], allLandmarks[7]],
  ),
  MiniTour(
    name: 'West Berlin Highlights',
    description: 'Discover the west side’s gems.',
    stops: [allLandmarks[6], allLandmarks[12], allLandmarks[15]],
  ),
];

double _distanceInKm(double lat1, double lng1, double lat2, double lng2) {
  const double R = 6371;
  double dLat = (lat2 - lat1) * pi / 180;
  double dLng = (lng2 - lng1) * pi / 180;
  double a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLng / 2) *
          sin(dLng / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

class MiniToursPage extends StatefulWidget {
  const MiniToursPage({super.key});
  @override
  State<MiniToursPage> createState() => _MiniToursPageState();
}

class _MiniToursPageState extends State<MiniToursPage> {
  Position? _position;
  String? _error;
  bool _loading = false;
  List<MiniTour> _highlightedTours = [];
  List<MiniTour> _favorites = [];
  final GlobalKey<AnimatedListState> _favListKey =
      GlobalKey<AnimatedListState>();

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled.';
          _loading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied.';
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions are permanently denied.';
          _loading = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _position = pos;
      });
      _highlightTours(pos);
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  void _highlightTours(Position pos) {
    List<MiniTour> found =
        miniTours.where((tour) {
          return tour.stops.any(
            (stop) =>
                _distanceInKm(
                  pos.latitude,
                  pos.longitude,
                  stop.lat,
                  stop.lng,
                ) <=
                3.0,
          );
        }).toList();
    setState(() {
      _highlightedTours = found;
    });
  }

  Widget _buildTourCard(MiniTour tour, {bool highlight = false}) {
    final isFavorite = _favorites.contains(tour);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: highlight ? Colors.amber[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (highlight)
            BoxShadow(
              color: Colors.amber.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tour.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isFavorite) {
                        _favorites.remove(tour);
                      } else {
                        _favorites.add(tour);
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tour.description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const Divider(),
            ...tour.stops.map(
              (stop) => ListTile(
                leading: const Icon(Icons.place, color: Colors.indigo),
                title: Text(
                  stop.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(stop.description),
                trailing: IconButton(
                  icon: const Icon(Icons.map),
                  tooltip: 'View on Map',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => MapPage(initialPlaceName: stop.name),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggested Mini-Tours')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.tour),
              label: const Text('Find Tours Near Me'),
              onPressed: _getLocation,
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_position != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Your location: ${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}',
                ),
              ),
            if (_highlightedTours.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Tours near you:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            if (_highlightedTours.isNotEmpty)
              ..._highlightedTours.map(
                (tour) => _buildTourCard(tour, highlight: true),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'All Berlin Mini-Tours:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: miniTours.length,
                itemBuilder: (context, index) {
                  final tour = miniTours[index];
                  return _buildTourCard(tour);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _favorites.isNotEmpty
              ? FloatingActionButton.extended(
                icon: const Icon(Icons.favorite),
                label: const Text('Favorites'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => ListView(
                          padding: const EdgeInsets.all(16),
                          children:
                              _favorites.isEmpty
                                  ? [const Text('No favorites yet.')]
                                  : _favorites
                                      .map((tour) => _buildTourCard(tour))
                                      .toList(),
                        ),
                  );
                },
              )
              : null,
    );
  }
}
