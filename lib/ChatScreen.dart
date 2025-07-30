import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'ChatMessage.dart';
import 'features/map/map_page.dart';
import 'package:latlong2/latlong.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // 🔐 Replace this with your Gemini API key from https://aistudio.google.com/app/apikey
  final String apiKey = 'AIzaSyBX67gWLxMVYLLSXNIltDNg-V1wSen1Je8';

  // Berlin places database
  final Map<String, List<Map<String, dynamic>>> _berlinPlaces = {
    'halal food': [
      {
        'name': 'Hasir Restaurant',
        'type': 'Turkish',
        'lat': 52.4996,
        'lng': 13.4033,
        'address': 'Adalbertstraße 10, 10999 Berlin',
      },
      {
        'name': 'Al-Dar Restaurant',
        'type': 'Lebanese',
        'lat': 52.5076,
        'lng': 13.3904,
        'address': 'Friedrichstraße 123, 10117 Berlin',
      },
      {
        'name': 'Sahara Restaurant',
        'type': 'Moroccan',
        'lat': 52.5163,
        'lng': 13.3777,
        'address': 'Potsdamer Straße 85, 10785 Berlin',
      },
      {
        'name': 'Maroush Restaurant',
        'type': 'Syrian',
        'lat': 52.5208,
        'lng': 13.2956,
        'address': 'Kantstraße 134, 10625 Berlin',
      },
      {
        'name': 'Al Safa Restaurant',
        'type': 'Pakistani',
        'lat': 52.5246,
        'lng': 13.4026,
        'address': 'Sonnenallee 23, 12047 Berlin',
      },
    ],
    'coffee': [
      {
        'name': 'The Barn Coffee Roasters',
        'type': 'Specialty Coffee',
        'lat': 52.5169,
        'lng': 13.4010,
        'address': 'Auguststraße 58, 10119 Berlin',
      },
      {
        'name': 'Five Elephant Coffee',
        'type': 'Coffee & Cake',
        'lat': 52.4996,
        'lng': 13.4033,
        'address': 'Reichenberger Straße 101, 10999 Berlin',
      },
      {
        'name': 'Bonanza Coffee Roasters',
        'type': 'Artisan Coffee',
        'lat': 52.5380,
        'lng': 13.4244,
        'address': 'Oderberger Straße 35, 10435 Berlin',
      },
      {
        'name': 'Father Carpenter',
        'type': 'Coffee & Brunch',
        'lat': 52.5138,
        'lng': 13.3926,
        'address': 'Münzstraße 21, 10178 Berlin',
      },
      {
        'name': 'Kaffee Mitte',
        'type': 'Local Coffee Shop',
        'lat': 52.5219,
        'lng': 13.4132,
        'address': 'Alexanderplatz 1, 10178 Berlin',
      },
    ],
    'pizza': [
      {
        'name': 'Standard Pizza',
        'type': 'Neapolitan',
        'lat': 52.4996,
        'lng': 13.4033,
        'address': 'Kottbusser Damm 95, 10999 Berlin',
      },
      {
        'name': 'Pizza Hut',
        'type': 'American Style',
        'lat': 52.5219,
        'lng': 13.4132,
        'address': 'Alexanderplatz 1, 10178 Berlin',
      },
      {
        'name': 'Domino\'s Pizza',
        'type': 'Fast Food',
        'lat': 52.5163,
        'lng': 13.3777,
        'address': 'Unter den Linden 77, 10117 Berlin',
      },
      {
        'name': 'Pizza Express',
        'type': 'Italian',
        'lat': 52.5076,
        'lng': 13.3904,
        'address': 'Friedrichstraße 123, 10117 Berlin',
      },
      {
        'name': 'Pizza Roma',
        'type': 'Traditional',
        'lat': 52.5208,
        'lng': 13.2956,
        'address': 'Kantstraße 134, 10625 Berlin',
      },
    ],
    'museum': [
      {
        'name': 'Pergamon Museum',
        'type': 'Archaeology',
        'lat': 52.5169,
        'lng': 13.4010,
        'address': 'Bodestraße 1-3, 10178 Berlin',
      },
      {
        'name': 'Neues Museum',
        'type': 'Egyptian Art',
        'lat': 52.5169,
        'lng': 13.4010,
        'address': 'Bodestraße 1-3, 10178 Berlin',
      },
      {
        'name': 'Alte Nationalgalerie',
        'type': '19th Century Art',
        'lat': 52.5169,
        'lng': 13.4010,
        'address': 'Bodestraße 1-3, 10178 Berlin',
      },
      {
        'name': 'Bode Museum',
        'type': 'Sculpture',
        'lat': 52.5169,
        'lng': 13.4010,
        'address': 'Bodestraße 1-3, 10178 Berlin',
      },
      {
        'name': 'Altes Museum',
        'type': 'Classical Antiquities',
        'lat': 52.5169,
        'lng': 13.4010,
        'address': 'Bodestraße 1-3, 10178 Berlin',
      },
    ],
    'park': [
      {
        'name': 'Tiergarten Park',
        'type': 'Central Park',
        'lat': 52.5145,
        'lng': 13.3501,
        'address': 'Tiergarten, 10785 Berlin',
      },
      {
        'name': 'Tempelhofer Feld',
        'type': 'Former Airport',
        'lat': 52.4730,
        'lng': 13.4036,
        'address': 'Tempelhofer Damm, 12101 Berlin',
      },
      {
        'name': 'Treptower Park',
        'type': 'Riverside Park',
        'lat': 52.4880,
        'lng': 13.4690,
        'address': 'Alt-Treptow, 12435 Berlin',
      },
      {
        'name': 'Volkspark Friedrichshain',
        'type': 'Recreation Park',
        'lat': 52.5270,
        'lng': 13.4180,
        'address': 'Am Friedrichshain, 10407 Berlin',
      },
      {
        'name': 'Görlitzer Park',
        'type': 'Neighborhood Park',
        'lat': 52.4996,
        'lng': 13.4033,
        'address': 'Görlitzer Straße, 10999 Berlin',
      },
    ],
    'shopping': [
      {
        'name': 'Kurfürstendamm',
        'type': 'Luxury Shopping',
        'lat': 52.5049,
        'lng': 13.3276,
        'address': 'Kurfürstendamm, 10719 Berlin',
      },
      {
        'name': 'Alexanderplatz',
        'type': 'Department Stores',
        'lat': 52.5219,
        'lng': 13.4132,
        'address': 'Alexanderplatz, 10178 Berlin',
      },
      {
        'name': 'Potsdamer Platz Arkaden',
        'type': 'Shopping Mall',
        'lat': 52.5096,
        'lng': 13.3750,
        'address': 'Potsdamer Platz, 10117 Berlin',
      },
      {
        'name': 'Mall of Berlin',
        'type': 'Modern Mall',
        'lat': 52.5096,
        'lng': 13.3750,
        'address': 'Leipziger Platz 12, 10117 Berlin',
      },
      {
        'name': 'Hackescher Markt',
        'type': 'Boutique Shopping',
        'lat': 52.5246,
        'lng': 13.4026,
        'address': 'Hackescher Markt, 10178 Berlin',
      },
    ],
  };

  // Helper: Find best place for any keyword
  Map<String, dynamic>? _findBestPlace(String userMessage) {
    final lower = userMessage.toLowerCase();
    for (final entry in _berlinPlaces.entries) {
      final category = entry.key;
      if (lower.contains(category) || lower.contains(category.split(' ')[0])) {
        return entry.value.first;
      }
      // Also check for keywords in each place type
      for (final place in entry.value) {
        if (lower.contains(place['type'].toString().toLowerCase()) ||
            lower.contains(place['name'].toString().toLowerCase())) {
          return place;
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        sender: "You",
        role: "user",
        text: """
You are a **friendly Berlin tour guide**. Your job is to:
- Give short, friendly, and helpful answers about Berlin.
- Use clear bullet points and headings (e.g., 'Top Sights', 'History', 'Tips').
- Limit replies to 4 lines maximum.
- Suggest Berlin attractions, museums, or neighborhoods when relevant.
- Never mention other cities or countries.
- Keep language simple and positive.
- When users ask for specific places (food, coffee, museums, parks, shopping), provide top 5 recommendations with brief descriptions.
""",
      ),
    );
    if (widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty) {
      Future.microtask(() => sendMessage(widget.initialMessage!));
    }
  }

  Future<void> sendMessage(String userMessage) async {
    setState(() {
      _messages.add(
        ChatMessage(role: "user", text: userMessage, sender: "You"),
      );
    });

    // Check for best place request
    final bestPlace = _findBestPlace(userMessage);
    if (bestPlace != null) {
      final reply =
          "The best place I recommend is **${bestPlace['name']}** (${bestPlace['type']}).\n" +
          "Address: ${bestPlace['address']}\n" +
          "Latitude: ${bestPlace['lat']}, Longitude: ${bestPlace['lng']}\n" +
          "Tap 'Show on Map' to view its location!";
      setState(() {
        _messages.add(
          ChatMessage(
            role: "model",
            text: reply,
            sender: "Gemini",
            places: [bestPlace],
          ),
        );
      });
      // Immediately open the map with this place
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => MapPage(
                  customPlaces: [bestPlace],
                  initialFocus: LatLng(bestPlace['lat'], bestPlace['lng']),
                ),
          ),
        );
      });
      return;
    }

    // Fallback: normal Gemini chat
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$apiKey',
    );

    final List<Map<String, dynamic>> history =
        _messages.map((msg) {
          return {
            "role": msg.role,
            "parts": [
              {"text": msg.text},
            ],
          };
        }).toList();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"contents": history}),
      );

      final data = jsonDecode(response.body);
      final reply = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      if (reply != null) {
        setState(() {
          _messages.add(
            ChatMessage(role: "model", text: reply, sender: "Gemini"),
          );
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              role: "model",
              sender: "Gemini",
              text: "⚠️ No reply from Gemini.",
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            role: "model",
            sender: "Gemini",
            text: "❌ Error contacting Gemini API.",
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleMessages = _messages.sublist(1); // hides prompt message in UI
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Berlin Guide',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: visibleMessages.length,
              itemBuilder: (_, index) {
                final msg = visibleMessages[index];
                final isUser = msg.sender == "You";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        color:
                            isUser
                                ? Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.15)
                                : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color:
                                      isUser ? Colors.indigo : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.sender,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (!isUser && msg.places != null) ...[
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.map, size: 18),
                                  label: const Text('Show on Map'),
                                  onPressed: () {
                                    final place = msg.places!.first;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MapPage(
                                              customPlaces: [place],
                                              initialFocus: LatLng(
                                                place['lat'],
                                                place['lng'],
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        sendMessage(value.trim());
                        _controller.clear();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      sendMessage(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                  child: const Icon(Icons.send, size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
