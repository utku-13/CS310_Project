import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  Future<String> getResponse(String userInput) async {
    print('Debug: Attempting to read GEMINI_API_KEY');
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    print('Debug: API Key found: ${apiKey != null ? 'Yes' : 'No'}');
    
    if (apiKey == null || apiKey.isEmpty) {
      print('Debug: API Key is null or empty');
      // Varsayılan bir yanıt döndür
      return "API anahtarı bulunamadı. .env dosyasını oluşturup GEMINI_API_KEY değerini ekleyin. Şimdilik size yardımcı olamıyorum. Lütfen sistem yöneticinizle iletişime geçin.";
    }

    try {
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
        return 'API yanıt vermedi. Hata kodu: ${response.statusCode}. Lütfen daha sonra tekrar deneyiniz.';
      }
    } catch (e) {
      print('Debug: Exception in API call: $e');
      return 'Bir bağlantı hatası oluştu. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';
    }
  }
} 