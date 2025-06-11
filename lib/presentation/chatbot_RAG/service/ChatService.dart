import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../ChatMessage.dart';

class ChatService {
  final String baseUrl = 'http://192.168.133.102:8000';

  Future<String> sendMessage(String message, List<ChatHistory> history) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'query': message,
          'chat_history': history.map((h) => h.toJson()).toList(),
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

  Stream<String> streamMessage(String message, List<ChatHistory> history) async* {
    try {
      developer.log('Preparing stream request...');
      final url = Uri.parse('$baseUrl/query/stream');
      developer.log('Request URL: $url');
      
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.headers['Cache-Control'] = 'no-cache';
      request.headers['Connection'] = 'keep-alive';
      
      final body = {
        'query': message,
        'chat_history': history.map((h) => h.toJson()).toList(),
      };
      request.body = jsonEncode(body);
      
      developer.log('Request body: ${request.body}');

      developer.log('Sending stream request...');
      final streamedResponse = await request.send();
      developer.log('Response status code: ${streamedResponse.statusCode}');
      
      if (streamedResponse.statusCode == 200) {
        developer.log('Luồng bắt đầu thành công');
        String buffer = '';
        bool hasData = false;
        String currentWord = '';
        bool isNewWord = true;
        
        await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
          developer.log('Nhận chunk thô: $chunk');
          
          if (chunk.isNotEmpty) {
            buffer += chunk;
            
            try {
              final jsonData = jsonDecode(buffer);
              if (jsonData is Map && jsonData.containsKey('answer')) {
                hasData = true;
                final answer = jsonData['answer'];
                developer.log('Trả về câu trả lời từ JSON: $answer');
                yield answer;
                buffer = ''; // Đặt lại buffer sau khi xử lý thành công
              }
            } catch (e) {
              // Xử lý từng ký tự
              for (var char in chunk.split('')) {
                if (char == ' ' || char == '\n' || char == '.' || char == ',' || char == ':' || char == ';') {
                  if (currentWord.isNotEmpty) {
                    hasData = true;
                    yield currentWord + char;
                    currentWord = ' ';
                    isNewWord = true;
                  } else if (char != ' ') {
                    yield char;
                  }
                } else {
                  if (isNewWord) {
                    currentWord = char;
                    isNewWord = false;
                  } else {
                    currentWord += char;
                  }
                }
              }
            }
          }
        }
        
        // Xử lý từ cuối cùng nếu còn
        if (currentWord.isNotEmpty) {
          yield currentWord;
        }
        
        if (!hasData) {
          developer.log('No data received from stream');
          yield "Xin lỗi, tôi không nhận được phản hồi từ server.";
        }
        
        developer.log('Stream completed');
      } else {
        final errorBody = await streamedResponse.stream.transform(utf8.decoder).join();
        developer.log('Stream error: ${streamedResponse.statusCode}');
        developer.log('Error body: $errorBody');
        throw Exception('Failed to stream message: ${streamedResponse.statusCode}\n$errorBody');
      }
    } catch (e) {
      developer.log('Stream error: $e');
      throw Exception('Error: $e');
    }
  }
}