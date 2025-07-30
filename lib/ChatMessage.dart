class ChatMessage {
  final String text;
  final String role;
  final String sender;
  final List<Map<String, dynamic>>? places;

  ChatMessage({
    required this.text,
    required this.role,
    required this.sender,
    this.places,
  });
}
