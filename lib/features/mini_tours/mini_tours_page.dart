import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiniToursPage extends StatefulWidget {
  const MiniToursPage({super.key});

  @override
  State<MiniToursPage> createState() => _MiniToursPageState();
}

class _MiniToursPageState extends State<MiniToursPage> {
  String _selectedDuration = 'All';
  final List<String> _durations = [
    'All',
    '1-2 hours',
    '3-4 hours',
    'Half day',
    'Full day',
  ];

  final List<Map<String, dynamic>> _tours = [
    {
      'name': 'Historical Berlin Walk',
      'duration': '3-4 hours',
      'distance': '4.2 km',
      'rating': 4.8,
      'price': '€25',
      'difficulty': 'Easy',
      'description':
          'Explore Berlin\'s most important historical sites including Brandenburg Gate, Reichstag, and Holocaust Memorial.',
      'highlights': [
        'Brandenburg Gate',
        'Reichstag',
        'Holocaust Memorial',
        'Checkpoint Charlie',
      ],
      'image': 'assets/icons/historical.png',
      'color': const Color(0xFF1E3A8A),
      'tags': ['History', 'Walking', 'Landmarks'],
      'tips': 'Start early to avoid crowds',
    },
    {
      'name': 'Art & Culture Tour',
      'duration': 'Half day',
      'distance': '3.1 km',
      'rating': 4.7,
      'price': '€35',
      'difficulty': 'Easy',
      'description':
          'Discover Berlin\'s vibrant art scene with visits to Museum Island, East Side Gallery, and contemporary galleries.',
      'highlights': [
        'Museum Island',
        'East Side Gallery',
        'Hamburger Bahnhof',
        'Kunsthaus Tacheles',
      ],
      'image': 'assets/icons/art.png',
      'color': const Color(0xFFF59E0B),
      'tags': ['Art', 'Culture', 'Museums'],
      'tips': 'Museum Island is free on Thursdays',
    },
    {
      'name': 'Food & Street Art',
      'duration': '2-3 hours',
      'distance': '2.8 km',
      'rating': 4.6,
      'price': '€20',
      'difficulty': 'Easy',
      'description':
          'Taste Berlin\'s best street food while exploring colorful street art in Kreuzberg and Friedrichshain.',
      'highlights': [
        'Currywurst',
        'Döner Kebab',
        'Street Art',
        'Markthalle Neun',
      ],
      'image': 'assets/icons/food.png',
      'color': const Color(0xFFDC2626),
      'tags': ['Food', 'Street Art', 'Local'],
      'tips': 'Try the currywurst at Curry 36',
    },
    {
      'name': 'Nature & Parks',
      'duration': 'Half day',
      'distance': '5.5 km',
      'rating': 4.5,
      'price': 'Free',
      'difficulty': 'Easy',
      'description':
          'Escape the city bustle with a peaceful walk through Berlin\'s most beautiful parks and gardens.',
      'highlights': [
        'Tiergarten',
        'Botanical Garden',
        'Tempelhofer Feld',
        'Victory Column',
      ],
      'image': 'assets/icons/nature.png',
      'color': const Color(0xFF10B981),
      'tags': ['Nature', 'Parks', 'Relaxation'],
      'tips': 'Perfect for picnics in summer',
    },
    {
      'name': 'Modern Architecture',
      'duration': '2-3 hours',
      'distance': '3.7 km',
      'rating': 4.4,
      'price': '€15',
      'difficulty': 'Easy',
      'description':
          'Marvel at Berlin\'s contemporary architecture including the TV Tower, Potsdamer Platz, and modern buildings.',
      'highlights': [
        'TV Tower',
        'Potsdamer Platz',
        'Sony Center',
        'Berlin Hauptbahnhof',
      ],
      'image': 'assets/icons/architecture.png',
      'color': const Color(0xFF7C3AED),
      'tags': ['Architecture', 'Modern', 'Urban'],
      'tips': 'Visit TV Tower at sunset for best views',
    },
    {
      'name': 'Nightlife & Bars',
      'duration': '3-4 hours',
      'distance': '2.2 km',
      'rating': 4.3,
      'price': '€30',
      'difficulty': 'Easy',
      'description':
          'Experience Berlin\'s legendary nightlife scene with visits to trendy bars, clubs, and entertainment venues.',
      'highlights': [
        'Kreuzberg Bars',
        'Berghain Area',
        'Hackescher Markt',
        'Prenzlauer Berg',
      ],
      'image': 'assets/icons/nightlife.png',
      'color': const Color(0xFF8B5CF6),
      'tags': ['Nightlife', 'Bars', 'Entertainment'],
      'tips': 'Start late - Berlin nightlife begins after 10 PM',
    },
  ];

  List<Map<String, dynamic>> get _filteredTours {
    if (_selectedDuration == 'All') {
      return _tours;
    }
    return _tours
        .where((tour) => tour['duration'] == _selectedDuration)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A8A),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mini Tours',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.route_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guided Mini Tours',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Curated routes to explore Berlin\'s best attractions',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Duration Filter
                  Text(
                    'Duration',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _durations.length,
                      itemBuilder: (context, index) {
                        final duration = _durations[index];
                        final isSelected = duration == _selectedDuration;

                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Text(
                              duration,
                              style: GoogleFonts.inter(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFF6B7280),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedDuration = duration;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF1E3A8A),
                            checkmarkColor: Colors.white,
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? const Color(0xFF1E3A8A)
                                      : const Color(0xFFE5E7EB),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Results Count
                  Row(
                    children: [
                      Text(
                        '${_filteredTours.length} tours found',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.sort_rounded),
                        onPressed: () {
                          // Sort functionality
                        },
                        color: const Color(0xFF1E3A8A),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tours List
                  ..._filteredTours.map((tour) => _buildTourCard(tour)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard(Map<String, dynamic> tour) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 4,
        shadowColor: const Color(0xFF1E3A8A).withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            _showTourDetails(tour);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tour['color'], tour['color'].withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tour['name'],
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tour['duration'],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.straighten_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tour['distance'],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tour['price'],
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour['description'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatItem(
                          Icons.star_rounded,
                          '${tour['rating']}',
                          const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          Icons.fitness_center_rounded,
                          tour['difficulty'],
                          const Color(0xFF10B981),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tour['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tour['tags'][0],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: tour['color'],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Highlights
                    Text(
                      'Highlights:',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          tour['highlights'].take(3).map<Widget>((highlight) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                highlight,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showTourDetails(tour);
                            },
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'Details',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tour['color'],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  void _showTourDetails(Map<String, dynamic> tour) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                tour['color'],
                                tour['color'].withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.route_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tour['name'],
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          tour['duration'] +
                                              ' • ' +
                                              tour['distance'],
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tour['price'],
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailStat(
                                Icons.star_rounded,
                                'Rating',
                                '${tour['rating']}',
                                const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailStat(
                                Icons.fitness_center_rounded,
                                'Difficulty',
                                tour['difficulty'],
                                const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailStat(
                                Icons.access_time_rounded,
                                'Duration',
                                tour['duration'],
                                const Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'About this tour',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tour['description'],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF374151),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Highlights
                        Text(
                          'Highlights',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...tour['highlights'].map<Widget>(
                          (highlight) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: tour['color'],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    highlight,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tips
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_rounded,
                                color: Color(0xFFF59E0B),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pro Tip',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF92400E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tour['tips'],
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons removed - functionality not implemented
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailStat(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
