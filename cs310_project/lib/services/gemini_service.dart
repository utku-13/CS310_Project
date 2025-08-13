import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';
  static const String _apiKey = 'AIzaSyDqpmCXLuhg1bTevQaG1DqUKnKcjnhxkMo';
  
  Future<String> getResponse(String userInput) async {
    try {
      print('Debug: Making API request to Gemini');
      print('Debug: User input: $userInput');
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
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
      print('Debug: Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Debug: Parsed JSON data: $data');
        
        final candidates = data['candidates'] as List?;
        print('Debug: Candidates: $candidates');
        
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          print('Debug: Content: $content');
          
          final parts = content['parts'] as List?;
          print('Debug: Parts: $parts');
          
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String;
            print('Debug: Extracted text: $text');
            return text;
          }
        }
        
        print('Debug: No valid response structure found, using default');
        return _getDefaultResponse(userInput);
      } else if (response.statusCode == 429) {
        print('Debug: Quota exceeded, using smart fallback');
        return _getSmartResponse(userInput);
      } else {
        print('Debug: Error response body: ${response.body}');
        return _getSmartResponse(userInput);
      }
    } catch (e) {
      print('Debug: Exception in API call: $e');
      return _getSmartResponse(userInput);
    }
  }

  String _getSmartResponse(String userInput) {
    // Kullanıcı mesajına göre daha akıllı yanıtlar
    final lowerInput = userInput.toLowerCase();
    
    // Selamlama yanıtları
    if (lowerInput.contains('merhaba') || lowerInput.contains('selam') || lowerInput.contains('hi') || lowerInput.contains('hey')) {
      final greetings = [
        'Merhaba! Size nasıl yardımcı olabilirim? Bugün kendinizi nasıl hissediyorsunuz?',
        'Selam! Hoş geldiniz. Bugün size nasıl destek olabilirim?',
        'Merhaba! Size yardımcı olmaya hazırım. Nasılsınız?',
      ];
      return greetings[DateTime.now().millisecond % greetings.length];
    }
    
    // Durum sorusu yanıtları
    if (lowerInput.contains('nasılsın') || lowerInput.contains('nasıl') || lowerInput.contains('iyi misin')) {
      final responses = [
        'Ben iyiyim, teşekkür ederim! Siz nasılsınız? Size nasıl destek olabilirim?',
        'Çok iyiyim! Sizinle konuşmak güzel. Siz nasılsınız?',
        'Harika! Size yardımcı olmaya hazırım. Siz nasılsınız?',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Negatif duygu yanıtları
    if (lowerInput.contains('üzgün') || lowerInput.contains('kötü') || lowerInput.contains('mutsuz') || lowerInput.contains('yorgun')) {
      final responses = [
        'Üzgün olduğunuzu duyduğuma üzüldüm. Bu duyguları yaşamak normal. Size nasıl yardımcı olabilirim? Belki biraz konuşmak ister misiniz?',
        'Kendinizi kötü hissetmeniz anlaşılır. Bu zor zamanlarda yanınızdayım. Ne oluyor?',
        'Yorgun ve üzgün hissetmek çok normal. Size destek olmak için buradayım. Ne konuşmak istersiniz?',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Pozitif duygu yanıtları
    if (lowerInput.contains('mutlu') || lowerInput.contains('iyi') || lowerInput.contains('güzel') || lowerInput.contains('harika')) {
      final responses = [
        'Harika! Mutlu olduğunuzu duymak güzel. Bu pozitif enerjiyi korumaya çalışın. Size başka nasıl yardımcı olabilirim?',
        'Çok güzel! Pozitif hissetmeniz harika. Bu enerjiyi sürdürmeye çalışın. Başka ne konuşmak istersiniz?',
        'Harika! İyi hissetmeniz çok güzel. Size bu konuda yardımcı olmaya devam edeyim.',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Stres ve endişe yanıtları
    if (lowerInput.contains('stres') || lowerInput.contains('gergin') || lowerInput.contains('endişe') || lowerInput.contains('kaygı')) {
      final responses = [
        'Stres ve endişe yaşamak çok normal. Derin nefes almayı deneyin. Size bu konuda yardımcı olmaya çalışayım. Ne oluyor?',
        'Stresli hissetmeniz anlaşılır. Bu duyguları yönetmek için size yardımcı olabilirim. Ne yaşıyorsunuz?',
        'Endişeli hissetmek zor. Size destek olmak için buradayım. Ne konuşmak istersiniz?',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Uyku yanıtları
    if (lowerInput.contains('uyku') || lowerInput.contains('uyumak') || lowerInput.contains('uykusuz')) {
      final responses = [
        'Uyku düzeni çok önemli. Rahat bir uyku için sakin bir ortam yaratın, ekranları kapatın ve rahatlayın. Uyku ile ilgili başka sorunlarınız var mı?',
        'Uyku kalitesi ruh sağlığı için çok önemli. Size uyku düzeninizi iyileştirmek için öneriler verebilirim. Ne yaşıyorsunuz?',
        'Uyku sorunları yaşamak yaygın. Size yardımcı olmaya çalışayım. Ne oluyor?',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Test mesajları
    if (lowerInput.contains('test') || lowerInput.contains('deneme') || lowerInput.contains('çalışıyor mu')) {
      final responses = [
        'Test mesajınızı aldım! Şu anda Gemini API quota limiti nedeniyle akıllı fallback yanıtlar veriyorum. Size gerçekten yardımcı olmaya çalışıyorum!',
        'Evet, çalışıyor! API limiti nedeniyle şu anda önceden hazırlanmış yanıtlar veriyorum ama size yardımcı olmaya devam ediyorum.',
        'Test başarılı! Şu anda akıllı yanıt sistemi çalışıyor. Size nasıl yardımcı olabilirim?',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // Genel yanıtlar
    return _getDefaultResponse(userInput);
  }

  String _getDefaultResponse(String userInput) {
    final responses = [
      'Merhaba! Size nasıl yardımcı olabilirim?',
      'Bu konuda size yardımcı olmaya çalışayım.',
      'Anlıyorum, bu konuda düşüncelerinizi paylaşmak istiyorsunuz.',
      'Size destek olmak için buradayım.',
      'Bu konuda daha fazla bilgi verebilir miyim?',
      'Kendinizi nasıl hissediyorsunuz?',
      'Bugün size nasıl yardımcı olabilirim?',
      'Bu konuda konuşmak istediğiniz başka bir şey var mı?',
      'Duygularınızı paylaşmak önemli. Size nasıl destek olabilirim?',
      'Bu konuda daha detaylı konuşmak ister misiniz?',
      'Size dinlemeye hazırım. Ne konuşmak istersiniz?',
      'Bu konuda size yardımcı olmaya çalışayım. Daha fazla detay verebilir misiniz?',
    ];
    
    // Basit bir hash fonksiyonu ile tutarlı yanıtlar
    final hash = userInput.hashCode.abs();
    return responses[hash % responses.length];
  }
} 