import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/favorite_chat.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Favorileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesProvider>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Chats'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final categoryFavorites = favoritesProvider.getFavoritesByCategory(category);
          
          if (categoryFavorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu kategoride henüz favori sohbet yok.',
                    style: AppStyles.bodyStyle.copyWith(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Yeni Sohbet Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            itemCount: categoryFavorites.length,
            itemBuilder: (context, index) {
              final favorite = categoryFavorites[index];
              return FavoriteChatCard(favorite: favorite);
            },
          );
        },
      ),
    );
  }
}

class FavoriteChatCard extends StatelessWidget {
  final FavoriteChat favorite;

  const FavoriteChatCard({
    super.key,
    required this.favorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      child: ListTile(
        title: Text(
          favorite.createdAt.toLocal().toString().split(' ')[0],
          style: AppStyles.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          favorite.preview,
          style: AppStyles.bodyStyle.copyWith(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                // Favoriden kaldır
                _confirmDelete(context, favorite);
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paylaşım özelliği henüz eklenmedi')),
                );
              },
            ),
          ],
        ),
        onTap: () {
          // Tam sohbeti göster
          _navigateToFullChat(context, favorite);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, FavoriteChat favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Favoriden Kaldır'),
        content: const Text('Bu sohbeti favorilerden kaldırmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<FavoritesProvider>(context, listen: false)
                  .removeFavorite(favorite.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sohbet favorilerden kaldırıldı')),
              );
            },
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );
  }

  void _navigateToFullChat(BuildContext context, FavoriteChat favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${favorite.category} - ${favorite.createdAt.toLocal().toString().split(' ')[0]}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kullanıcı mesajı
              Container(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppStyles.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    favorite.userMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              
              // AI yanıtı
              Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    favorite.aiResponse,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          if (favorite.chatId != null)
            TextButton(
              onPressed: () {
                // Konuşmaya devam et
                Navigator.pop(context);
                Navigator.pushNamed(
                  context, 
                  '/chat',
                  arguments: favorite.chatId
                );
              },
              child: const Text('Devam Et'),
            ),
          TextButton(
            onPressed: () {
              // Yeni bir sohbete başla
              Navigator.pop(context);
              Navigator.pushNamed(context, '/chat');
            },
            child: const Text('Yeni Sohbet'),
          ),
        ],
      ),
    );
  }
} 