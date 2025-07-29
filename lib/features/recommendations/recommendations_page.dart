import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../map/map_page.dart';

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
    description: 'One of the world’s most famous zoos.',
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

double _distanceInKm(double lat1, double lng1, double lat2, double lng2) {
  const double R = 6371; // Earth radius in km
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

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});
  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  Position? _position;
  String? _error;
  bool _loading = false;
  List<Attraction> _near3 = [];
  List<Attraction> _near5 = [];
  List<Attraction> _farther = [];

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
      _findNearby(pos);
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

  void _findNearby(Position pos) {
    List<Attraction> near3 = [];
    List<Attraction> near5 = [];
    List<Attraction> farther = [];
    for (final a in attractions) {
      final dist = _distanceInKm(pos.latitude, pos.longitude, a.lat, a.lng);
      if (dist <= 3.0) {
        near3.add(a);
      } else if (dist <= 5.0) {
        near5.add(a);
      } else {
        farther.add(a);
      }
    }
    setState(() {
      _near3 = near3;
      _near5 = near5;
      _farther = farther;
    });
  }

  Widget _buildAttractionList(
    String title,
    List<Attraction> list,
    Color color,
  ) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
        ),
        ...list.map(
          (a) => Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.place, color: Colors.indigo),
              title: Text(
                a.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.description),
                  Text(
                    'Note: ${a.note}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.map),
                tooltip: 'View on Map',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapPage(initialPlaceName: a.name),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Attractions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Find Nearby Attractions'),
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
            Expanded(
              child: ListView(
                children: [
                  _buildAttractionList('Within 3 km', _near3, Colors.green),
                  _buildAttractionList('Within 5 km', _near5, Colors.orange),
                  _buildAttractionList(
                    'Farther than 5 km',
                    _farther,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
