import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoading = false;
  String? _currentChatId;

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
      final chatId = await _saveChatToFirestore(userMessage, response);
      _currentChatId = chatId;

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

  Future<String> _saveChatToFirestore(String userMessage, String aiResponse) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = await FirebaseFirestore.instance.collection('chats').add({
          'userId': user.uid,
          'userMessage': userMessage,
          'aiResponse': aiResponse,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return docRef.id;
      }
    } catch (e) {
      print('Error saving chat to Firestore: $e');
    }
    return '';
  }

  void _addToFavorites() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir sohbet başlatın')),
      );
      return;
    }

    // Kategori seçim dialogunu göster
    final selectedCategory = await _showCategorySelectionDialog();
    if (selectedCategory != null) {
      try {
        // Mesajlardan önizleme, kullanıcı mesajı ve AI yanıtı oluştur
        final preview = _getPreview();
        final userMessage = _getUserMessage();
        final aiResponse = _getAIResponse();
        
        // Provider ile favorilere ekle
        final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
        await favoritesProvider.addFavorite(
          category: selectedCategory, 
          preview: preview,
          userMessage: userMessage,
          aiResponse: aiResponse
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sohbet "$selectedCategory" kategorisine eklendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sohbet eklenirken bir hata oluştu')),
        );
      }
    }
  }

  Future<String?> _showCategorySelectionDialog() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final categories = favoritesProvider.categories;
    String? selectedCategory;
    final TextEditingController customCategoryController = TextEditingController();

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
                  const SizedBox(height: 16),
                  TextField(
                    controller: customCategoryController,
                    decoration: const InputDecoration(
                      labelText: 'Veya yeni kategori ekleyin',
                      border: OutlineInputBorder(),
                    ),
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
                  if (customCategoryController.text.isNotEmpty) {
                    final newCategory = customCategoryController.text.trim();
                    favoritesProvider.addCategory(newCategory);
                    Navigator.pop(context, newCategory);
                  } else if (selectedCategory != null) {
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

  String _getPreview() {
    // Son mesajlardan ön izleme oluştur (en fazla 2 mesaj)
    if (_messages.isEmpty) return '';
    
    final previewMessages = _messages.length > 2 
        ? _messages.sublist(_messages.length - 2) 
        : _messages;
    
    return previewMessages.map((m) {
      final prefix = m.isUser ? 'Sen: ' : 'AI: ';
      final text = m.text.length > 50 ? '${m.text.substring(0, 50)}...' : m.text;
      return '$prefix$text';
    }).join('\n');
  }

  String _getUserMessage() {
    // Kullanıcının son mesajını getir
    final userMessages = _messages.where((m) => m.isUser).toList();
    return userMessages.isNotEmpty ? userMessages.last.text : '';
  }

  String _getAIResponse() {
    // AI'ın son yanıtını getir
    final aiMessages = _messages.where((m) => !m.isUser).toList();
    return aiMessages.isNotEmpty ? aiMessages.last.text : '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Support'),
        backgroundColor: AppStyles.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: _addToFavorites,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(AppStyles.smallPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.defaultPadding,
                        vertical: AppStyles.smallPadding,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: AppStyles.smallPadding),
                CircleAvatar(
                  backgroundColor: AppStyles.primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
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

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.smallPadding),
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.defaultPadding,
          vertical: AppStyles.smallPadding,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppStyles.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
} 