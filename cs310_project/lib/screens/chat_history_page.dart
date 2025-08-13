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

class _ChatHistoryPageState extends State<ChatHistoryPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Favorileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesProvider>(context, listen: false).loadFavorites();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;
    
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppStyles.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.history,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$category Sohbetleri',
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
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppStyles.primaryGradient,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                  ),
                ],
              ),
            );
          }
          
          final categoryFavorites = favoritesProvider.getFavoritesByCategory(category);
          
          if (categoryFavorites.isEmpty) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppStyles.textLightColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: AppStyles.textLightColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bu kategoride henüz favori sohbet yok',
                        style: AppStyles.headingSmallStyle.copyWith(
                          fontSize: 20,
                          color: AppStyles.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Yeni bir sohbet başlatarak favorilerinizi oluşturabilirsiniz',
                        style: AppStyles.bodyMediumStyle.copyWith(
                          fontSize: 16,
                          color: AppStyles.textLightColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppStyles.primaryGradient,
                          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                          boxShadow: AppStyles.elevatedShadow,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/chat');
                          },
                          icon: const Icon(Icons.chat, color: Colors.white),
                          label: const Text(
                            'Yeni Sohbet Başlat',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppStyles.largePadding,
                              vertical: AppStyles.defaultPadding,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              itemCount: categoryFavorites.length,
              itemBuilder: (context, index) {
                final favorite = categoryFavorites[index];
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final delay = index * 0.1;
                    final animation = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(delay, delay + 0.6, curve: Curves.easeOutCubic),
                    ));
                    
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - animation.value)),
                      child: Opacity(
                        opacity: animation.value,
                        child: FavoriteChatCard(favorite: favorite),
                      ),
                    );
                  },
                );
              },
            ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      decoration: AppStyles.elevatedCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToFullChat(context, favorite),
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppStyles.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.chat,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favorite.createdAt.toLocal().toString().split(' ')[0],
                            style: AppStyles.bodyStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppStyles.textPrimaryColor,
                            ),
                          ),
                          Text(
                            '${favorite.category} kategorisi',
                            style: AppStyles.captionStyle.copyWith(
                              color: AppStyles.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppStyles.textSecondaryColor,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'delete':
                            _confirmDelete(context, favorite);
                            break;
                          case 'share':
                            _shareChat(context, favorite);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share, color: AppStyles.infoColor, size: 20),
                              const SizedBox(width: 8),
                              Text('Paylaş', style: AppStyles.bodyMediumStyle),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: AppStyles.errorColor, size: 20),
                              const SizedBox(width: 8),
                              Text('Favorilerden Kaldır', style: AppStyles.bodyMediumStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(AppStyles.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppStyles.backgroundColor,
                    borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
                    border: Border.all(
                      color: AppStyles.textLightColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sohbet Önizlemesi:',
                        style: AppStyles.captionStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppStyles.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        favorite.preview,
                        style: AppStyles.bodyMediumStyle.copyWith(
                          color: AppStyles.textPrimaryColor,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FavoriteChat favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppStyles.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: AppStyles.errorColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Favoriden Kaldır',
              style: AppStyles.headingSmallStyle,
            ),
          ],
        ),
        content: Text(
          'Bu sohbeti favorilerden kaldırmak istediğinize emin misiniz?',
          style: AppStyles.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppStyles.bodyStyle.copyWith(
                color: AppStyles.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<FavoritesProvider>(context, listen: false)
                  .removeFavorite(favorite.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Sohbet favorilerden kaldırıldı'),
                    ],
                  ),
                  backgroundColor: AppStyles.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );
  }

  void _shareChat(BuildContext context, FavoriteChat favorite) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text('Paylaşım özelliği henüz eklenmedi'),
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

  void _navigateToFullChat(BuildContext context, FavoriteChat favorite) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.largeBorderRadius),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppStyles.defaultPadding),
                decoration: BoxDecoration(
                  gradient: AppStyles.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppStyles.largeBorderRadius),
                    topRight: Radius.circular(AppStyles.largeBorderRadius),
                  ),
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
                        Icons.chat,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${favorite.category} - ${favorite.createdAt.toLocal().toString().split(' ')[0]}',
                            style: AppStyles.headingSmallStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Sohbet Detayları',
                            style: AppStyles.bodyMediumStyle.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppStyles.defaultPadding),
                  child: Column(
                    children: [
                      // Kullanıcı mesajı
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(AppStyles.defaultPadding),
                          decoration: BoxDecoration(
                            gradient: AppStyles.primaryGradient,
                            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                            boxShadow: AppStyles.cardShadow,
                          ),
                          child: Text(
                            favorite.userMessage,
                            style: AppStyles.bodyStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      // AI yanıtı
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(AppStyles.defaultPadding),
                          decoration: BoxDecoration(
                            color: AppStyles.backgroundColor,
                            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                            border: Border.all(
                              color: AppStyles.textLightColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            favorite.aiResponse,
                            style: AppStyles.bodyStyle.copyWith(
                              color: AppStyles.textPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppStyles.defaultPadding),
                decoration: BoxDecoration(
                  color: AppStyles.backgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppStyles.largeBorderRadius),
                    bottomRight: Radius.circular(AppStyles.largeBorderRadius),
                  ),
                ),
                child: Row(
                  children: [
                    if (favorite.chatId != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context, 
                              '/chat',
                              arguments: favorite.chatId
                            );
                          },
                          icon: const Icon(Icons.chat_bubble),
                          label: const Text('Devam Et'),
                          style: AppStyles.primaryButtonStyle,
                        ),
                      ),
                    if (favorite.chatId != null)
                      const SizedBox(width: AppStyles.smallPadding),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/chat');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Yeni Sohbet'),
                        style: AppStyles.secondaryButtonStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 