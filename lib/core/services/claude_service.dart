import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class ClaudeMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final String? fileName;

  ClaudeMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.fileName,
  });
}

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  late final String _apiKey;

  ClaudeService() {
    _apiKey = dotenv.env['CLAUDE_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('Claude API key not found in environment variables');
    }
  }

  Future<String> getResponse(String message, {File? file}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      request.headers.addAll({
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      });

      var messageData = {
        'model': 'claude-3-opus-20240229',
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content':
                '''You are a nutrition and health assistant for the NutriTrack app. 
            Provide concise, accurate responses about nutrition, meal planning, calorie tracking, and BMI. 
            Current request: $message'''
          }
        ],
      };

      if (file != null) {
        final mimeType = lookupMimeType(file.path);
        if (mimeType == null) {
          throw Exception('Unsupported file type');
        }

        final fileStream = http.ByteStream(file.openRead());
        final fileLength = await file.length();

        final multipartFile = http.MultipartFile(
          'file',
          fileStream,
          fileLength,
          filename: path.basename(file.path),
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);

        // Robust handling of messageData structure
        if (messageData.containsKey('messages') &&
            messageData['messages'] is List) {
          final messages = messageData['messages'] as List;
          if (messages.isNotEmpty) {
            final firstMessage = messages[0];
            if (firstMessage is Map && firstMessage.containsKey('content')) {
              firstMessage['content'] = (firstMessage['content'] ?? '') +
                  '\n(Analyzing attached file: ${path.basename(file.path)})';
            } else {
              // Handle missing 'content' key or incorrect type
              print(
                  "Warning: messageData['messages'][0] does not have a 'content' key or is not a Map.");
              //Option 1: throw an exception
              //throw FormatException("Invalid message structure: Missing 'content' key.");

              //Option 2: create the key:
              messages[0] = {
                'content':
                    '\n(Analyzing attached file: ${path.basename(file.path)})'
              };
            }
          } else {
            // Handle empty messages list
            print("Warning: messageData['messages'] is an empty list.");
            //Option 1: throw an exception
            //throw FormatException("Invalid message structure: Empty messages list.");
            //Option 2: create the list:
            messageData['messages'] = [
              {
                'content':
                    '\n(Analyzing attached file: ${path.basename(file.path)}'
              }
            ];
          }
        } else {
          print(
              "Warning: messageData does not have a 'messages' key or it is not a List.");
          //Option 1: throw an exception
          //throw FormatException("Invalid message structure: Missing 'messages' key.");
          //Option 2: create the key:
          messageData['messages'] = [
            {
              'content':
                  '\n(Analyzing attached file: ${path.basename(file.path)}'
            }
          ];
        }
      }

      request.fields['message'] = json.encode(messageData);

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseString);
        return data['content'][0]['text'];
      } else {
        print('API Error: ${response.statusCode}, Response: $responseString');
        throw Exception(
            'API Error: ${response.statusCode}'); // Re-throwing the exception after printing.
      }
    } catch (e) {
      print('Error getting Claude response: ${e.toString()}');
      throw Exception('Failed to get response: $e');
    }
  }

  bool isSupportedFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return [
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.csv',
      '.jpg',
      '.jpeg',
      '.png',
      '.gif'
    ].contains(extension);
  }
}
