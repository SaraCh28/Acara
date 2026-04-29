import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import 'event_service.dart';

class AiService {
  final Ref _ref;
  // Replace with your actual backend URL
  static const String _baseUrl = 'https://your-backend-api.com/ai';

  AiService(this._ref);

  Future<String> getAiResponse(String message) async {
    final events = _ref.read(eventsProvider);
    
    // Formatting events for the AI context
    final eventContext = events.map((e) => {
      'id': e.id,
      'title': e.title,
      'category': e.category,
      'date': e.date.toIso8601String(),
      'city': e.city,
      'price': e.price,
    }).toList();

    // Simulate a short delay for "thinking"
    await Future.delayed(const Duration(seconds: 1));

    final msg = message.toLowerCase();
    
    if (msg.contains('hello') || msg.contains('hi')) {
      return 'Hello! I am your Acara Assistant. I can help you find events or answer questions about the app. What are you looking for today?';
    }

    if (msg.contains('event') || msg.contains('show') || msg.contains('looking for')) {
      if (events.isEmpty) {
        return 'I don’t see any local events right now. Try changing your city to see what’s happening elsewhere!';
      }
      
      final event = events.first;
      return 'I found some great events! For example, "${event.title}" is happening in ${event.city} on ${event.date.day}/${event.date.month}. Would you like to know more about it?';
    }

    if (msg.contains('free')) {
      final freeEvents = events.where((e) => e.price == 0).toList();
      if (freeEvents.isNotEmpty) {
        return 'Yes! There are ${freeEvents.length} free events available, including "${freeEvents.first.title}".';
      }
      return 'I couldn’t find any free events in your current selection, but keep checking back!';
    }

    if (msg.contains('how') && msg.contains('book')) {
      return 'To book a ticket, just click on any event you like, and you’ll see a "Book Ticket" button at the bottom. It only takes a minute!';
    }

    return 'That’s interesting! I’m still learning about that topic, but I can certainly help you browse categories or find events near you. Is there anything specific about events you’d like to know?';
  }
}

final aiServiceProvider = Provider((ref) => AiService(ref));
