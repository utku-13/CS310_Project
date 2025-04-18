import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class ChatLibraryPage extends StatelessWidget {
  const ChatLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Anxiety',
      'Depression',
      'Stress Management',
      'Self-Care',
      'Relationships',
      'Work-Life Balance',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Library'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
            child: ListTile(
              title: Text(
                categories[index],
                style: AppStyles.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'View your saved chats about ${categories[index].toLowerCase()}',
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
                  arguments: categories[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
} 