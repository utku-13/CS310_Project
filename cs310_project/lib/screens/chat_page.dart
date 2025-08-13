import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/gemini_service.dart';
import '../services/database_service.dart';
import '../models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

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

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  String? _currentChatId;
  
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForChatId();
    });
  }
  
  @override
  void dispose() {
    _typingAnimationController.dispose();
    super.dispose();
  }
  
  void _checkForChatId() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _currentChatId = args;
      _loadChatById(args);
    } else {
      setState(() {
        _messages.clear();
        _currentChatId = null;
      });
      
      if (_messages.isEmpty) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "Merhaba! Ben AIWell, yapay zeka destekli ruh sağlığı asistanınız. Size nasıl yardımcı olabilirim?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    }
  }
  
  Future<void> _loadChatById(String chatId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final chat = await _databaseService.getChatById(chatId);
      if (chat != null) {
        setState(() {
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
        });
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('Error loading chat by id: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    print('Debug: Adding user message: $userMessage');
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
    print('Debug: User message added, loading set to true. Total messages: ${_messages.length}');

    String aiResponse = "Üzgünüm, şu anda bağlantı sorunu yaşıyorum. Lütfen daha sonra tekrar deneyin.";
    
    try {
      // Get response from Gemini
      print('Debug: Calling Gemini service...');
      aiResponse = await _geminiService.getResponse(userMessage);
      print('Debug: Gemini response received: $aiResponse');
    } catch (e) {
      print('Error getting Gemini response: $e');
      // Gemini API hatası durumunda varsayılan yanıt kullanılacak
    }
    
    // Firestore kaydetme kısmını geçici olarak devre dışı bırak
    print('Debug: Skipping Firestore save for now...');
    
    print('Debug: Adding AI response: $aiResponse');
    setState(() {
      _messages.add(
        ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
    });
    print('Debug: AI message added, loading set to false. Total messages: ${_messages.length}');

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.largeBorderRadius),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.defaultPadding),
                    decoration: BoxDecoration(
                      gradient: AppStyles.primaryGradient,
                      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Favorilere Ekle',
                            style: AppStyles.headingSmallStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppStyles.defaultPadding),
                  Text(
                    'Bu sohbeti hangi kategoriye eklemek istiyorsunuz?',
                    style: AppStyles.bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppStyles.defaultPadding),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppStyles.textLightColor.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppStyles.defaultPadding,
                          ),
                          child: Text(
                            'Kategori seçin',
                            style: AppStyles.bodyMediumStyle.copyWith(
                              color: AppStyles.textSecondaryColor,
                            ),
                          ),
                        ),
                        value: selectedCategory,
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppStyles.defaultPadding,
                              ),
                              child: Text(
                                category,
                                style: AppStyles.bodyStyle,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppStyles.defaultPadding),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: AppStyles.outlineButtonStyle,
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: AppStyles.smallPadding),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedCategory != null) {
                              Navigator.pop(context, selectedCategory);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Lütfen bir kategori seçin'),
                                    ],
                                  ),
                                  backgroundColor: AppStyles.warningColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
                                  ),
                                ),
                              );
                            }
                          },
                          style: AppStyles.primaryButtonStyle,
                          child: const Text('Ekle'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _currentChatId = null;
      
      _messages.add(
        ChatMessage(
          text: "Merhaba! Yeni bir sohbet başlattınız. Size nasıl yardımcı olabilirim?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppStyles.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AI Sohbet',
              style: AppStyles.headingSmallStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Yeni Sohbet',
              onPressed: _startNewChat,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              tooltip: 'Favorilere Ekle',
              onPressed: () async {
                if (_messages.length >= 2) {
                  final category = await _showCategorySelectionDialog();
                  if (category != null) {
                    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
                    try {
                      final int lastIndex = _messages.length - 1;
                      final String aiMessage = _messages[lastIndex].text;
                      final String userMessage = _messages[lastIndex - 1].text;
                      
                      await favoritesProvider.addFavorite(
                        category: category,
                        preview: aiMessage,
                        userMessage: userMessage,
                        aiResponse: aiMessage,
                        chatId: _currentChatId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Favorilere eklendi'),
                            ],
                          ),
                          backgroundColor: AppStyles.successColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Hata: $e'),
                            ],
                          ),
                          backgroundColor: AppStyles.errorColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Önce mesaj göndermelisiniz'),
                        ],
                      ),
                      backgroundColor: AppStyles.infoColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
                      ),
                    ),
                  );
                }
              },
            ),
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
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppStyles.defaultPadding,
                vertical: AppStyles.smallPadding,
              ),
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              decoration: BoxDecoration(
                color: AppStyles.backgroundColor,
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                border: Border.all(
                  color: AppStyles.textLightColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppStyles.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI düşünüyor',
                    style: AppStyles.bodyMediumStyle.copyWith(
                      color: AppStyles.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _typingAnimationController,
                    builder: (context, child) {
                      _typingAnimationController.repeat();
                      return Row(
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppStyles.primaryColor.withOpacity(
                                0.3 + (0.7 * _typingAnimation.value),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.all(AppStyles.defaultPadding),
            padding: const EdgeInsets.all(AppStyles.smallPadding),
            decoration: AppStyles.elevatedCardDecoration,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: AppStyles.textFieldDecoration(
                      'Mesajınızı yazın...',
                      hint: 'Size nasıl yardımcı olabilirim?',
                    ).copyWith(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.defaultPadding,
                        vertical: AppStyles.smallPadding,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: AppStyles.smallPadding),
                  decoration: BoxDecoration(
                    gradient: AppStyles.primaryGradient,
                    borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                    boxShadow: AppStyles.cardShadow,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                    tooltip: 'Gönder',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: AppStyles.smallPadding,
          left: message.isUser ? 60 : 0,
          right: message.isUser ? 0 : 60,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppStyles.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(AppStyles.defaultPadding),
                decoration: BoxDecoration(
                  color: message.isUser 
                    ? AppStyles.primaryColor 
                    : AppStyles.backgroundColor,
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                  boxShadow: message.isUser 
                    ? AppStyles.cardShadow 
                    : null,
                  border: !message.isUser 
                    ? Border.all(
                        color: AppStyles.textLightColor.withOpacity(0.2),
                      )
                    : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: AppStyles.bodyStyle.copyWith(
                        color: message.isUser 
                          ? Colors.white 
                          : AppStyles.textPrimaryColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(message.timestamp),
                      style: AppStyles.captionStyle.copyWith(
                        color: message.isUser 
                          ? Colors.white.withOpacity(0.8)
                          : AppStyles.textLightColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppStyles.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: AppStyles.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 