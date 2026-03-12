import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/dog.dart';
import '../models/trigger_log.dart';
import '../models/training_plan.dart';

/// Service for all AI-powered features using Claude API (claude-opus-4-6).
/// Handles training plan generation, progress analysis, and real-time coaching.
class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-opus-4-6';
  static const String _anthropicVersion = '2023-06-01';

  String get _apiKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
    'anthropic-version': _anthropicVersion,
  };

  /// System prompt for the AI dog trainer persona
  static const String _trainerSystemPrompt = '''
Sen, reaktif ve kaygılı köpekler konusunda uzmanlaşmış, pozitif pekiştirme
yöntemlerini kullanan deneyimli bir köpek eğitmenisin. Türkiye'de çalışıyorsun
ve kullanıcılarla Türkçe iletişim kuruyorsun.

Uzmanlık alanların:
- Reaktif köpek rehabilitasyonu (BAT 2.0, LAT, counter-conditioning)
- Desensitizasyon protokolleri
- Korku temelli agresyon yönetimi
- Ayrılık kaygısı
- Gürültü fobisi (tüfek, havai fişek, gök gürültüsü)
- Pozitif pekiştirme ve işaret eğitimi

Prensiplerin:
1. ASLA ceza, sert ses, itme, çekme gibi zorlayıcı yöntemler önerme
2. Köpeğin eşiğinin HEP altında kal (sub-threshold training)
3. Köpeğin vücut dilini oku ve anlat
4. Gerçekçi ve ulaşılabilir hedefler koy
5. Sahibini destekle, suçlama (bu süreç streslidir)
6. Güvenlik önlemlerini vurgula
7. Gerektiğinde veteriner/uzman yönlendirmesi yap

Yanıtlarını şefkatli, destekleyici ve pratik tut. Her zaman Türkçe yanıt ver.
''';

  /// Generate a personalized training plan for a dog based on their profile and logs
  Future<Map<String, dynamic>> generateTrainingPlan({
    required Dog dog,
    required String targetTrigger,
    required List<TriggerLog> recentLogs,
  }) async {
    final logsContext = recentLogs.take(10).map((log) => '''
- Tarih: ${log.date.toString().substring(0, 10)}
- Tetikleyici: ${log.trigger}
- Yoğunluk: ${log.intensityLabel}
- İyileşme süresi: ${log.recoveryLabel}
- Tetikleyiciye mesafe: ${log.distanceToTrigger.round()} metre
- Sakinleştirici kullanıldı mı: ${log.usedCalming ? 'Evet (${log.calmingTechnique})' : 'Hayır'}
''').join('\n');

    final prompt = '''
Aşağıdaki köpek için "${targetTrigger}" tetikleyicisine karşı 4 haftalık bir eğitim planı hazırla.

KÖPEK PROFİLİ:
- İsim: ${dog.name}
- Irk: ${dog.breed}
- Yaş: ${dog.ageString}
- Boyut: ${dog.sizeLabel}
- Reaktivite seviyesi: ${dog.reactivityLabel}
- Bilinen tetikleyiciler: ${dog.triggers.join(', ')}
- Korkuları: ${dog.fears.join(', ')}
${dog.notes != null ? '- Sahip notları: ${dog.notes}' : ''}

SON 10 OTURUMDAN VERİLER:
$logsContext

Lütfen JSON formatında yanıt ver (başka hiçbir şey yazma, sadece JSON):
{
  "title": "Plan başlığı",
  "description": "Genel açıklama (2-3 cümle)",
  "approach": "Kullanılan yaklaşım (örn: CC+DS, BAT 2.0)",
  "importantNotes": ["Önemli güvenlik notu 1", "Önemli güvenlik notu 2"],
  "weeks": [
    {
      "weekNumber": 1,
      "goal": "Bu haftanın hedefi",
      "focusTrigger": "Odak tetikleyici",
      "notes": "Koç notları",
      "exercises": [
        {
          "id": "w1e1",
          "title": "Egzersiz adı",
          "description": "Açıklama",
          "technique": "Teknik adı",
          "durationMinutes": 5,
          "difficultyLevel": 1,
          "steps": ["Adım 1", "Adım 2", "Adım 3"],
          "materials": ["Yüksek değerli ödül", "Tasma"],
          "successCriteria": "Başarı kriteri"
        }
      ]
    }
  ]
}
''';

    final response = await _callClaude(prompt);
    return jsonDecode(response) as Map<String, dynamic>;
  }

  /// Analyze progress from trigger logs and provide insights
  Future<String> analyzeProgress({
    required Dog dog,
    required List<TriggerLog> logs,
    required String targetTrigger,
  }) async {
    if (logs.isEmpty) {
      return '${dog.name} için henüz kayıt yok. İlk eğitim oturumundan sonra burada ilerleme analizini göreceksin!';
    }

    final recentLogs = logs
        .where((l) => l.trigger == targetTrigger)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final logsSummary = recentLogs.take(15).map((log) => '''
${log.date.toString().substring(0, 10)}: ${log.intensityLabel} tepki, ${log.recoveryLabel} iyileşme, ${log.distanceToTrigger.round()}m mesafe
''').join('');

    final prompt = '''
${dog.name} isimli köpeğin "${targetTrigger}" tetikleyicisine karşı son oturumlarını analiz et:

$logsSummary

Kısa (3-5 cümle), pozitif ama gerçekçi bir ilerleme analizi yap.
- Gözlemlediğin eğilimi belirt
- Somut ilerlemeleri vurgula
- Bir sonraki hedefi öner
Türkçe yaz, sahibe hitap et.
''';

    return _callClaude(prompt);
  }

  /// Get real-time coaching tip based on current situation
  Future<String> getRealTimeTip({
    required Dog dog,
    required String currentSituation,
    required String triggerer,
  }) async {
    final prompt = '''
ACIL KOÇ DESTEĞİ - Şu an yürüyüşteyim!

Köpeğim: ${dog.name} (${dog.breed}, ${dog.reactivityLabel})
Şu anki durum: $currentSituation
Tetikleyici: $triggerer

Şu an ne yapmalıyım? 3 pratik adım ver. Kısa ve net ol.
Türkçe yaz.
''';

    return _callClaude(prompt, maxTokens: 300);
  }

  /// Generate a calming script for anxious moments
  Future<String> generateCalmingScript({
    required Dog dog,
    required String trigger,
  }) async {
    final prompt = '''
${dog.name} şu an ${trigger} nedeniyle stresli.
Sahibine köpeğini sakinleştirmeye yardımcı olacak
adım adım bir senaryo yaz (2-3 dakika sürecek).
Ses tonu, vücut dili ve teknikler dahil.
Türkçe, pratik ve yatıştırıcı bir dille yaz.
''';

    return _callClaude(prompt, maxTokens: 400);
  }

  /// Generate a community tip based on experience
  Future<String> generateCommunityTip({
    required String spotName,
    required String dogDescription,
    required String experience,
  }) async {
    final prompt = '''
Bir reaktif köpek sahibi şu deneyimini paylaşmak istiyor:
Yer: $spotName
Köpek: $dogDescription
Deneyim: $experience

Bunu diğer reaktif köpek sahipleri için faydalı bir ipucuna dönüştür.
2-3 cümle, pratik ve destekleyici.
Türkçe yaz.
''';

    return _callClaude(prompt, maxTokens: 200);
  }

  /// Core Claude API call
  Future<String> _callClaude(
    String userMessage, {
    int maxTokens = 2000,
    bool useThinking = false,
  }) async {
    final body = <String, dynamic>{
      'model': _model,
      'max_tokens': maxTokens,
      'system': _trainerSystemPrompt,
      'messages': [
        {'role': 'user', 'content': userMessage},
      ],
    };

    if (useThinking) {
      body['thinking'] = {'type': 'adaptive'};
    }

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw ClaudeException(
        'API hatası: ${response.statusCode} - ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;

    // Find the text block
    for (final block in content) {
      if (block['type'] == 'text') {
        return block['text'] as String;
      }
    }

    throw const ClaudeException('API yanıtında metin bulunamadı');
  }

  /// Stream a response from Claude for real-time display
  Stream<String> streamClaude(String userMessage) async* {
    final body = jsonEncode({
      'model': _model,
      'max_tokens': 1000,
      'stream': true,
      'system': _trainerSystemPrompt,
      'messages': [
        {'role': 'user', 'content': userMessage},
      ],
    });

    final request = http.Request('POST', Uri.parse(_baseUrl));
    request.headers.addAll(_headers);
    request.body = body;

    final streamedResponse = await request.send();
    final stream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in stream) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data == '[DONE]') break;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          if (json['type'] == 'content_block_delta') {
            final delta = json['delta'] as Map<String, dynamic>;
            if (delta['type'] == 'text_delta') {
              yield delta['text'] as String;
            }
          }
        } catch (_) {
          // Skip malformed lines
        }
      }
    }
  }
}

class ClaudeException implements Exception {
  final String message;
  final int? statusCode;

  const ClaudeException(this.message, {this.statusCode});

  @override
  String toString() => 'ClaudeException: $message';
}
