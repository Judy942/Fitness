import 'package:flutter/material.dart';

import 'ChatWidget.dart';

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const ChatScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trò chuyện với AI'),
      ),
      body: ChatWidget(userData: userData),
    );
  }
} 