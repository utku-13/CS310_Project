import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/gemini_service.dart';
import '../services/database_service.dart';
import '../models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  String? _currentChatId;

  @override
  void initState() {
    super.initState();
    _loadPreviousChats();
  }

  Future<void> _loadPreviousChats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _databaseService.getUserChats(user.uid).listen((chats) {
      setState(() {
        _messages.clear();
        for (var chat in chats) {
          _messages.add(
            ChatMessage(
              text: chat.userMessage,
              isUser: true,
              timestamp: chat.timestamp,
            ),
          );
          _messages.add(
            ChatMessage(
              text: chat.aiResponse,
              isUser: false,
              timestamp: chat.timestamp,
            ),
          );
        }
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    try {
      // Get response from Gemini
      final response = await _geminiService.getResponse(userMessage);
      
      // Save chat to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final chat = ChatModel(
          id: '',
          userId: user.uid,
          userMessage: userMessage,
          aiResponse: response,
          timestamp: DateTime.now(),
        );
        _currentChatId = await _databaseService.saveChat(chat);
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Sorry, I'm having trouble connecting right now. Please try again later.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      print('Error getting Gemini response: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String?> _showCategorySelectionDialog() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final categories = favoritesProvider.categories;
    String? selectedCategory;

    return showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Kategori Seçin'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Kategori seçin'),
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedCategory != null) {
                    Navigator.pop(context, selectedCategory);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen bir kategori seçin')),
                    );
                  }
                },
                child: const Text('Ekle'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () async {
              if (_currentChatId != null) {
                final category = await _showCategorySelectionDialog();
                if (category != null) {
                  final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
                  await favoritesProvider.addFavorite(
                    category: category,
                    preview: _messages.last.text,
                    userMessage: _messages[_messages.length - 2].text,
                    aiResponse: _messages.last.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser ? AppStyles.primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 