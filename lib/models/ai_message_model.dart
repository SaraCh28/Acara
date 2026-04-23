enum MessageRole { user, assistant }

class AiMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  AiMessage({
    required this.text,
    required this.role,
    required this.timestamp,
  });
}
