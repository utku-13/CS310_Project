import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class DailyTipsPage extends StatefulWidget {
  const DailyTipsPage({super.key});

  @override
  State<DailyTipsPage> createState() => _DailyTipsPageState();
}

class _DailyTipsPageState extends State<DailyTipsPage> {
  final List<Map<String, dynamic>> _tips = [
    {
      'title': 'Morning Mindfulness',
      'description': 'Start your day with 5 minutes of mindful breathing. Find a quiet space, sit comfortably, and focus on your breath. This practice can help reduce stress and improve focus throughout the day.',
      'category': 'Mindfulness',
      'duration': '5 minutes',
      'isExpanded': false,
    },
    {
      'title': 'Gratitude Journaling',
      'description': 'Take a moment to write down three things you\'re grateful for today. This simple practice can help shift your focus to positive aspects of life and improve overall well-being.',
      'category': 'Self-Care',
      'duration': '10 minutes',
      'isExpanded': false,
    },
    {
      'title': 'Digital Detox',
      'description': 'Set aside 30 minutes without screens. Use this time to connect with nature, read a book, or engage in a creative activity. This break from digital stimulation can help reduce anxiety and improve sleep quality.',
      'category': 'Digital Wellness',
      'duration': '30 minutes',
      'isExpanded': false,
    },
    {
      'title': 'Progressive Muscle Relaxation',
      'description': 'Practice progressive muscle relaxation by tensing and then relaxing each muscle group in your body. Start from your toes and work your way up to your head. This technique can help reduce physical tension and promote relaxation.',
      'category': 'Stress Management',
      'duration': '15 minutes',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tips'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        itemCount: _tips.length,
        itemBuilder: (context, index) {
          final tip = _tips[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
            child: ExpansionTile(
              title: Text(
                tip['title'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${tip['category']} • ${tip['duration']}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppStyles.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['description'] as String,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: AppStyles.defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {
                              // TODO: Implement save to favorites
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to favorites'),
                                  backgroundColor: Colors.green,
                                ),
                              );
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 