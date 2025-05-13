import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import 'ChatMessage.dart';
import 'service/ChatService.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '1');
  final _chatService = ChatService();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Ẩn bàn phím khi mất focus
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSendPressed(types.PartialText message) async {
    if (message.text.trim().isEmpty) return;

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _textController.clear();
    });

    try {
      log('Starting stream request...');
      String fullResponse = '';
      String messageId = DateTime.now().toString();
      bool isFirstChunk = true;
      
      await for (String chunk in _chatService.streamMessage(
        message.text,
        _messages.map((m) => ChatMessage(
          text: (m as types.TextMessage).text,
          isUser: m.author.id == _user.id,
          timestamp: DateTime.fromMillisecondsSinceEpoch(m.createdAt!),
        )).toList(),
      )) {
        log('Processing chunk: $chunk');
        fullResponse += chunk;
        
        if (isFirstChunk) {
          // Tạo message mới cho chunk đầu tiên
          final botMessage = types.TextMessage(
            author: const types.User(id: '2'),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: messageId,
            text: fullResponse,
          );
          setState(() {
            _messages.insert(0, botMessage);
          });
          isFirstChunk = false;
        } else {
          // Cập nhật message hiện tại cho các chunk tiếp theo
          setState(() {
            if (_messages.isNotEmpty && _messages[0].author.id == '2') {
              _messages[0] = types.TextMessage(
                author: const types.User(id: '2'),
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: messageId,
                text: fullResponse,
              );
            }
          });
        }
        // Thêm delay nhỏ để tạo hiệu ứng stream
        await Future.delayed(const Duration(milliseconds: 50));
      }
      log('Stream completed');
    } catch (e) {
      log('Stream error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildMessage(types.CustomMessage message, {required int messageWidth}) {
    final isUser = message.author.id == _user.id;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: isUser ? const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ) : null,
        color: isUser ? null : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message.metadata?['text'] as String? ?? '',
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        customMessageBuilder: _buildMessage,
        theme: DefaultChatTheme(
          primaryColor: Colors.blue,
          secondaryColor: Colors.grey[200]!,
          backgroundColor: Colors.white,
          inputBackgroundColor: Colors.grey[100]!,
          inputTextColor: Colors.black,
          inputTextCursorColor: Colors.black,
        ),
      ),
    );
  }
}