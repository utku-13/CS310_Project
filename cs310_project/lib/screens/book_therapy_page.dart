import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class BookTherapyPage extends StatelessWidget {
  const BookTherapyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Therapy'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emergency Section
            _buildEmergencySection(context),
            const SizedBox(height: AppStyles.defaultPadding * 2),
            
            // Available Therapists Section
            _buildTherapistsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencySection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppStyles.defaultPadding),
            const Text(
              'If you are in crisis or feeling suicidal, please contact emergency services immediately.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: AppStyles.defaultPadding),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement emergency call functionality
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Emergency Contact'),
                    content: const Text('Call 112 for emergency services.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement actual call functionality
                          Navigator.pop(context);
                        },
                        child: const Text('Call'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Emergency Contact',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTherapistsSection(BuildContext context) {
    // Sample therapist data
    final therapists = [
      {
        'name': 'Dr. Sarah Johnson',
        'specialty': 'Anxiety & Depression',
        'experience': '10 years',
        'rating': 4.8,
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Trauma & PTSD',
        'experience': '8 years',
        'rating': 4.9,
      },
      {
        'name': 'Dr. Emily Rodriguez',
        'specialty': 'Relationship Counseling',
        'experience': '12 years',
        'rating': 4.7,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Therapists',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppStyles.defaultPadding),
        ...therapists.map((therapist) => Card(
          margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppStyles.defaultPadding),
            title: Text(
              therapist['name'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Specialty: ${therapist['specialty']}'),
                Text('Experience: ${therapist['experience']}'),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text(' ${therapist['rating']}'),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _showBookingDialog(context, therapist);
              },
              child: const Text('Book Session'),
            ),
          ),
        )).toList(),
      ],
    );
  }

  void _showBookingDialog(BuildContext context, Map<String, dynamic> therapist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Session with ${therapist['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select preferred date and time:'),
            const SizedBox(height: AppStyles.defaultPadding),
            // TODO: Implement date and time picker
            const Text('Available slots will be shown here'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement booking functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session booked successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
} 