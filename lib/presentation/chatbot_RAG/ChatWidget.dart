import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../../core/utils/app_colors.dart';
import 'ChatMessage.dart';
import 'service/ChatService.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final List<types.Message> _messages = [];
  final List<ChatHistory> _chatHistory = [];
  final _user = const types.User(id: '1');
  final _chatService = ChatService();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _loadingTimer;
  String _loadingDots = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('ChatWidget initialized');
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
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startLoadingAnimation() {
    debugPrint('Starting loading animation');
    if (!mounted) {
      debugPrint('Widget not mounted, skipping loading animation');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _loadingDots = '';
    });
    
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        debugPrint('Widget not mounted during timer, cancelling');
        timer.cancel();
        return;
      }
      setState(() {
        if (_loadingDots.length >= 3) {
          _loadingDots = '';
        } else {
          _loadingDots += '.';
        }
      });
    });
    debugPrint('Loading animation setup completed');
  }

  void _stopLoadingAnimation() {
    debugPrint('Stopping loading animation');
    if (!mounted) {
      debugPrint('Widget not mounted, skipping stop loading animation');
      return;
    }
    
    setState(() {
      _isLoading = false;
    });
    _loadingTimer?.cancel();
    _loadingTimer = null;
    debugPrint('Loading animation stopped');
  }

  void _handleSendPressed(types.PartialText message) async {
    if (message.text.trim().isEmpty) return;

    debugPrint('Handling send pressed with message: ${message.text}');

    // Thêm message của user
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

    // Bắt đầu animation loading
    _startLoadingAnimation();

    try {
      debugPrint('Starting stream request...');
      String fullResponse = '';
      String messageId = DateTime.now().toString();
      bool isFirstChunk = true;
      
      await for (String chunk in _chatService.streamMessage(
        message.text,
        _chatHistory,
      )) {
        debugPrint('Processing chunk: $chunk');
        fullResponse += chunk;
        
        if (isFirstChunk) {
          // Dừng loading khi nhận được chunk đầu tiên
          _stopLoadingAnimation();
          isFirstChunk = false;
          
          // Tạo message mới cho câu trả lời
          setState(() {
            _messages.insert(0, types.TextMessage(
              author: const types.User(id: '2'),
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: messageId,
              text: fullResponse,
            ));
          });
        } else {
          // Cập nhật message hiện có với nội dung mới
          setState(() {
            final index = _messages.indexWhere((m) => m.id == messageId);
            if (index != -1) {
              _messages[index] = types.TextMessage(
                author: const types.User(id: '2'),
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: messageId,
                text: fullResponse,
              );
            }
          });
        }
      }
      
      // Thêm vào lịch sử chat sau khi hoàn thành
      setState(() {
        _chatHistory.add(ChatHistory(
          user: message.text,
          assistant: fullResponse,
        ));
      });
      
      // Đảm bảo loading được dừng khi stream hoàn thành
      if (_isLoading) {
        _stopLoadingAnimation();
      }
      
      debugPrint('Stream completed');
    } catch (e) {
      debugPrint('Error occurred: $e');
      _stopLoadingAnimation();
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
    debugPrint('Building ChatWidget, isLoading: $_isLoading');
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Chat(
            messages: _messages,
            hideBackgroundOnEmojiMessages: false,
            
            onSendPressed: _handleSendPressed,
            user: _user,
            customMessageBuilder: _buildMessage,
            theme: DefaultChatTheme(
              
              primaryColor: AppColors.primaryColor1,
              secondaryColor: Colors.grey[200]!,
              backgroundColor: Colors.white,
              inputBackgroundColor: Colors.grey[100]!,
              inputTextColor: Colors.black,
              inputTextCursorColor: Colors.black,
              inputTextStyle: TextStyle(color: Colors.black),
            ),
          ),
          if (_isLoading)
            Positioned(
              bottom: 80,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đang trả lời$_loadingDots',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}