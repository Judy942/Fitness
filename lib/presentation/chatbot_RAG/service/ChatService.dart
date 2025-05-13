import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../ChatMessage.dart';

class ChatService {
  final String baseUrl = 'http://192.168.64.186:8000';

  Future<String> sendMessage(String message, List<ChatMessage> history) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'query': message,
          'chat_history': history.map((msg) => {
            'user': msg.isUser ? msg.text : '',
            'assistant': msg.isUser ? '' : msg.text,
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['answer'];
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Stream<String> streamMessage(String message, List<ChatMessage> history) async* {
    try {
      developer.log('Preparing stream request...');
      final request = http.Request('POST', Uri.parse('$baseUrl/query/stream'));
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.body = jsonEncode({
        'query': message,
        'chat_history': history.map((msg) => {
          'user': msg.isUser ? msg.text : '',
          'assistant': msg.isUser ? '' : msg.text,
        }).toList(),
      });

      developer.log('Sending stream request...');
      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode == 200) {
        developer.log('Stream started successfully');
        String buffer = '';
        await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
          developer.log('Received chunk size: ${chunk.length}');
          developer.log('Chunk content: $chunk');
          
          if (chunk.isNotEmpty) {
            // Thử chia nhỏ chunk thành các phần
            final parts = chunk.split(RegExp(r'(?<=[.!?])\s+'));
            for (var part in parts) {
              if (part.isNotEmpty) {
                developer.log('Yielding part: $part');
                yield part + ' ';
              }
            }
          }
        }
        developer.log('Stream completed');
      } else {
        developer.log('Stream error: ${streamedResponse.statusCode}');
        throw Exception('Failed to stream message: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      developer.log('Stream error: $e');
      throw Exception('Error: $e');
    }
  }
}