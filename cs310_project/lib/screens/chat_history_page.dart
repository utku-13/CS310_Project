import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;
    
    // Sample saved chats
    final savedChats = [
      {
        'date': '2024-04-15',
        'preview': 'I was feeling really anxious about my upcoming exam...',
      },
      {
        'date': '2024-04-10',
        'preview': 'I had a difficult conversation with my friend...',
      },
      {
        'date': '2024-04-05',
        'preview': 'I was struggling with work-life balance...',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Chats'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        itemCount: savedChats.length,
        itemBuilder: (context, index) {
          final chat = savedChats[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
            child: ListTile(
              title: Text(
                chat['date']!,
                style: AppStyles.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                chat['preview']!,
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
                      // TODO: Implement delete functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                  ),
                ],
              ),
              onTap: () {
                // TODO: Show full chat
              },
            ),
          );
        },
      ),
    );
  }
} 