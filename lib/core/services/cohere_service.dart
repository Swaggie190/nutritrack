import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nutritrack/core/services/chatbot_service.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class CohereService implements ChatBotService {
  static const String _baseUrl = 'https://api.cohere.com/v1/chat';
  late final String _apiKey;

  CohereService() {
    _apiKey = dotenv.env['COHERE_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('Cohere API key not found in environment variables');
    }
  }

  @override
  Future<String> getResponse(String message, {File? file}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'Authorization': 'bearer $_apiKey',
        },
        body: json.encode({
          'message': message,
          'chat_history': [],
          'model': 'command-r-08-2024',
          'preamble':
              '''You are a nutrition and health assistant for the NutriTrack app. 
            Provide concise, accurate responses about nutrition, meal planning, calorie tracking, and BMI. '''
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['text'] ?? 'No response generated';
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get response: $e');
    }
  }

  @override
  bool isSupportedFileType(String filePath) {
    // Cohere might have different file support than Claude
    final extension = path.extension(filePath).toLowerCase();
    return ['.txt', '.csv', '.jpg', '.jpeg', '.png'].contains(extension);
  }
}
