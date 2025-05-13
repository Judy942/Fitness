
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import 'ChatMessage.dart';
import 'service/ChatService.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '1');
  final _chatService = ChatService();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    try {
      final response = await _chatService.sendMessage(
        message.text,
        _messages.map((m) => ChatMessage(
          text: (m as types.TextMessage).text,
          isUser: m.author.id == _user.id,
          timestamp: DateTime.fromMillisecondsSinceEpoch(m.createdAt!),
        )).toList(),
      );

      final botMessage = types.TextMessage(
        author: const types.User(id: '2'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().toString(),
        text: response,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat với AI'),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
          primaryColor: Theme.of(context).primaryColor,
          secondaryColor: Colors.grey[200]!,
          backgroundColor: Colors.white,
          inputBackgroundColor: Colors.grey,
          inputTextCursorColor: Colors.black,
          inputTextStyle: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
} 