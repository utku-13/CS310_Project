import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class ChatLibraryPage extends StatefulWidget {
  const ChatLibraryPage({super.key});

  @override
  State<ChatLibraryPage> createState() => _ChatLibraryPageState();
}

class _ChatLibraryPageState extends State<ChatLibraryPage> {
  @override
  void initState() {
    super.initState();
    // Load favorites when the page is initialized
    Future.microtask(() => 
      Provider.of<FavoritesProvider>(context, listen: false).loadFavorites()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Library'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = favoritesProvider.categories;
          
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryFavorites = favoritesProvider.getFavoritesByCategory(category);
              
              return Card(
                margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
                child: ListTile(
                  title: Text(
                    category,
                    style: AppStyles.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${categoryFavorites.length} saved chats about ${category.toLowerCase()}',
                    style: AppStyles.bodyStyle.copyWith(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat-history',
                      arguments: category,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 