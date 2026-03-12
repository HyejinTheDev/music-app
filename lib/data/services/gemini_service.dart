import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service đóng gói Gemini API cho chat AI
/// Hỗ trợ fallback sang chế độ demo khi API không khả dụng
class GeminiService {
  static const String _apiKey =
      'AIzaSyA8NlDl-kUDRPWTYiWTmAEATZYyce18rdg';

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  final List<Map<String, dynamic>> _history = [];
  bool _useDemoMode = false;

  /// Gửi tin nhắn và nhận phản hồi
  Future<String> sendMessage(String message) async {
    // Nếu đang ở chế độ demo, trả lời demo
    if (_useDemoMode) {
      return _getDemoResponse(message);
    }

    try {
      // Thêm tin nhắn user vào history
      _history.add({
        'role': 'user',
        'parts': [{'text': message}],
      });

      final body = jsonEncode({
        'contents': [
          // System prompt
          {
            'role': 'user',
            'parts': [{'text': 'Bạn là trợ lý âm nhạc thông minh tên "Music AI". Trả lời bằng tiếng Việt, ngắn gọn, dùng emoji. Chỉ nói về âm nhạc.'}],
          },
          {
            'role': 'model',
            'parts': [{'text': 'Xin chào! Tôi là Music AI 🎵 Hãy hỏi tôi bất cứ điều gì về âm nhạc nhé!'}],
          },
          // Chat history
          ..._history,
        ],
      });

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

        // Thêm phản hồi AI vào history
        _history.add({
          'role': 'model',
          'parts': [{'text': text}],
        });

        return text;
      } else if (response.statusCode == 429) {
        // Quota exceeded → chuyển sang demo mode
        debugPrint('[GeminiService] ⚠️ Quota exceeded → chuyển sang demo mode');
        _useDemoMode = true;
        return '⚠️ API đang bị giới hạn, chuyển sang chế độ demo.\n\n${_getDemoResponse(message)}';
      } else {
        debugPrint('[GeminiService] ❌ Error ${response.statusCode}: ${response.body}');
        _useDemoMode = true;
        return '⚠️ Không thể kết nối AI, chuyển sang chế độ demo.\n\n${_getDemoResponse(message)}';
      }
    } catch (e) {
      debugPrint('[GeminiService] ❌ Exception: $e');
      _useDemoMode = true;
      return '⚠️ Lỗi kết nối, chuyển sang chế độ demo.\n\n${_getDemoResponse(message)}';
    }
  }

  /// Xóa lịch sử chat
  void clearHistory() {
    _history.clear();
    _useDemoMode = false; // Reset thử lại API
  }

  /// Chế độ demo — trả lời thông minh dựa trên từ khóa
  String _getDemoResponse(String message) {
    final msg = message.toLowerCase();
    final random = Random();

    if (msg.contains('gợi ý') || msg.contains('recommend') || msg.contains('suggest')) {
      final suggestions = [
        '🎵 Đây là một số bài hát hay cho bạn:\n\n'
            '1. 🎤 "Có Chắc Yêu Là Đây" - Sơn Tùng M-TP\n'
            '2. 🎸 "Nơi Này Có Anh" - Sơn Tùng M-TP\n'
            '3. 🎹 "Hãy Trao Cho Anh" - Sơn Tùng M-TP ft. Snoop Dogg\n'
            '4. 🎧 "Chúng Ta Của Hiện Tại" - Sơn Tùng M-TP\n'
            '5. 🎶 "Lạc Trôi" - Sơn Tùng M-TP\n\n'
            'Bạn thích thể loại nào? 😊',
        '🎵 Top bài hát V-Pop hot nhất:\n\n'
            '1. 🔥 "Waiting For You" - MONO\n'
            '2. 💫 "See Tình" - Hoàng Thuỳ Linh\n'
            '3. 🌟 "Đừng Làm Trái Tim Anh Đau" - Sơn Tùng M-TP\n'
            '4. 💖 "Anh Sai Rồi" - Đức Phúc\n'
            '5. 🎤 "Em Của Ngày Hôm Qua" - Sơn Tùng M-TP\n\n'
            'Muốn nghe thêm gợi ý không? 🎧',
      ];
      return suggestions[random.nextInt(suggestions.length)];
    }

    if (msg.contains('rock') || msg.contains('rock')) {
      return '🎸 Top nghệ sĩ Rock huyền thoại:\n\n'
          '1. 🤘 Queen - "Bohemian Rhapsody" là kiệt tác!\n'
          '2. 🎸 Led Zeppelin - "Stairway to Heaven"\n'
          '3. 🔥 AC/DC - "Back in Black"\n'
          '4. 💀 Guns N\' Roses - "Sweet Child O\' Mine"\n'
          '5. 🎵 Pink Floyd - "Comfortably Numb"\n\n'
          'Rock VN thì có Bức Tường, Trần Lập! 🇻🇳';
    }

    if (msg.contains('thư giãn') || msg.contains('relax') || msg.contains('chill')) {
      return '🧘 Nhạc thư giãn cho bạn:\n\n'
          '1. 🌊 "Lofi Hip Hop" - ChilledCow\n'
          '2. 🌸 "River Flows In You" - Yiruma\n'
          '3. ☕ "Kiếp Ve Sầu" - Piano Cover\n'
          '4. 🍃 "Nhật Ký Của Mẹ" - Hiền Thục (Acoustic)\n'
          '5. 🌙 "Trước Khi Em Ngủ" - Nhạc Piano\n\n'
          'Nghe nhạc thư giãn giúp giảm stress rất tốt! 💆‍♂️';
    }

    if (msg.contains('lời') || msg.contains('lyric') || msg.contains('giải thích')) {
      return '📝 Mình có thể giúp giải thích lời bài hát!\n\n'
          'Bạn muốn tìm hiểu lời bài nào? Hãy gửi tên bài hát '
          'và mình sẽ giải thích ý nghĩa cho bạn. 🎶\n\n'
          'Ví dụ: "Giải thích lời bài Lạc Trôi"';
    }

    if (msg.contains('hello') || msg.contains('hi') || msg.contains('xin chào') || msg.contains('hey')) {
      return 'Xin chào! 👋🎵\n\n'
          'Mình là Music AI - trợ lý âm nhạc của bạn!\n\n'
          'Mình có thể giúp bạn:\n'
          '🎤 Gợi ý bài hát hay\n'
          '🎸 Giới thiệu nghệ sĩ\n'
          '📝 Giải thích lời bài hát\n'
          '🎧 Tìm nhạc theo mood\n\n'
          'Hỏi mình bất cứ điều gì nhé! 😊';
    }

    // Default response
    final defaults = [
      '🎵 Câu hỏi hay đó! Về âm nhạc, mình gợi ý bạn thử nghe '
          '"Bohemian Rhapsody" của Queen - một kiệt tác vượt thời gian! 🎸\n\n'
          'Bạn muốn mình gợi ý thêm nhạc gì không? 😊',
      '🎶 Mình rất thích nói về âm nhạc!\n\n'
          'Bạn có thể hỏi mình về:\n'
          '• Gợi ý bài hát 🎤\n'
          '• Top nghệ sĩ Rock 🎸\n'
          '• Nhạc thư giãn 🧘\n'
          '• Giải thích lời bài hát 📝\n\n'
          'Hỏi thử đi nào! 🎧',
      '🎤 Bạn có biết không? Bài hát "Happy Birthday" là một trong '
          'những bài hát được hát nhiều nhất thế giới! 🎂\n\n'
          'Mình sẵn sàng chat về nhạc nè. Hỏi mình đi! 🎵',
    ];
    return defaults[random.nextInt(defaults.length)];
  }
}
