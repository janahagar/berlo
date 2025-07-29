import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ChatMessage.dart';
import 'features/map/map_page.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  // 🔐 Replace this with your Gemini API key from https://aistudio.google.com/app/apikey
  final String apiKey = 'AIzaSyBX67gWLxMVYLLSXNIltDNg-V1wSen1Je8';

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
""",
      ),
    );
    if (widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty) {
      Future.microtask(() => sendMessage(widget.initialMessage!));
    }
  }

  Future<void> sendMessage(String userMessage) async {
    // Add user message to the chat
    setState(() {
      _messages.add(
        ChatMessage(role: "user", text: userMessage, sender: "You"),
      );
    });

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$apiKey',
    );

    // Prepare history for Gemini
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

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      final data = jsonDecode(response.body);
      final reply = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
      print('REPLY: $reply');

      if (reply != null) {
        setState(() {
          _messages.add(
            ChatMessage(role: "model", text: reply, sender: "Gemini"),
          );
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
      print("Error: $e");
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
      appBar: AppBar(title: const Text("Gemini Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                              if (!isUser &&
                                  _extractPlaceName(msg.text) != null)
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.map),
                                      label: const Text('Show on Map'),
                                      onPressed: () {
                                        final place =
                                            _extractPlaceName(msg.text)!;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => MapPage(
                                                  initialPlaceName: place,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.directions),
                                      label: const Text('How to Get There'),
                                      onPressed: () {
                                        final place =
                                            _extractPlaceName(msg.text)!;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => MapPage(
                                                  initialPlaceName: place,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
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

// Add this helper method to extract a known place name from Gemini's reply
String? _extractPlaceName(String text) {
  final knownPlaces = [
    'Brandenburg Gate',
    'Museum Island',
    'Berlin Cathedral',
    'East Side Gallery',
    'Checkpoint Charlie',
    'Gendarmenmarkt',
    'Charlottenburg Palace',
    'Tempelhofer Feld',
    'Kreuzberg Street Art',
    'Tiergarten Park',
    'Potsdamer Platz',
    'Victory Column',
    'Berlin Zoo',
    'Hackescher Markt',
    'Prenzlauer Berg',
    'Olympic Stadium',
  ];
  for (final place in knownPlaces) {
    if (text.contains(place)) return place;
  }
  return null;
}
