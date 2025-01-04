import 'dart:io'; //import for File usage

//Chat BotService for a variety of AI services
abstract class ChatBotService {
  Future<String> getResponse(String message, {File? file});
  bool isSupportedFileType(String filePath);
}
