import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sagebible/core/config/ai_config.dart';
import 'package:sagebible/core/services/supabase_service.dart';
import 'package:sagebible/features/ai/models/chat_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Fetch chat history for user
  Future<List<ChatMessage>> fetchChatHistory(String userId) async {
    try {
      final response = await _supabase
          .from('chat_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (response as List).map((item) {
        return ChatMessage(
          text: item['content'],
          isUser: item['role'] == 'user',
        );
      }).toList();
    } catch (e) {
      // If table doesn't exist or other error, return empty list
      print('Error fetching chat history: $e');
      return [];
    }
  }

  /// Save message to history
  Future<void> saveMessage(String userId, String role, String content) async {
    try {
      await _supabase.from('chat_history').insert({
        'user_id': userId,
        'role': role,
        'content': content,
      });
    } catch (e) {
      print('Error saving chat message: $e');
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${AIConfig.baseUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${AIConfig.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': AIConfig.model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful and knowledgeable Bible assistant. '
                  'Answer questions based on biblical teachings. '
                  'Provide references to verses where appropriate. '
                  'Keep answers concise and encouraging.'
            },
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error communicating with AI: $e');
    }
  }
}
