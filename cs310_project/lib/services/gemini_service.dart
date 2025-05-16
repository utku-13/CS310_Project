import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  Future<String> getResponse(String userInput) async {
    print('Debug: Attempting to read GEMINI_API_KEY');
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    print('Debug: API Key found: ${apiKey != null ? 'Yes' : 'No'}');
    
    if (apiKey == null) {
      print('Debug: API Key is null, throwing exception');
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    print('Debug: Making API request to Gemini');
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': userInput}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        }
      }),
    );

    print('Debug: Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      print('Debug: Error response body: ${response.body}');
      throw Exception('Failed to get Gemini response: ${response.statusCode}');
    }
  }
} 