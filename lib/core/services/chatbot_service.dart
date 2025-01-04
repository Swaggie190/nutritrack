import 'dart:io';

abstract class ChatBotService {
  Future<String> getResponse(String message, {File? file});
  bool isSupportedFileType(String filePath);
}
