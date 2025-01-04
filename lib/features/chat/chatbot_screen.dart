import 'package:flutter/material.dart';
import 'package:nutritrack/core/services/chatbot_service.dart';
import '../../core/constants/theme_constants.dart';

//Uncomment the line bellow to use Claude AI services instead
//import '../../core/services/claude_service.dart';
import '../../core/services/cohere_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late final ChatBotService _chatBotService;
  bool _isLoading = false;
  File? _selectedFile;

  //pre prepared message requests
  static const List<String> _suggestedQuestions = [
    "What's my ideal BMI range?",
    "Create a meal plan for weight loss",
    "Analyze my food diary",
    "Suggest healthy snacks"
  ];

  //initialization...
  @override
  void initState() {
    super.initState();
    _chatBotService = CohereService();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      //This is the very first message sent by the Bot
      _addBotMessage(
        "Welcome to NutriTrack AI Assistant! 👋\n\n"
        "I can help you with:\n"
        "• Meal planning and nutrition advice\n"
        "• Calorie calculations\n"
        "• BMI analysis\n"
        "• Diet recommendations\n\n"
        "You can also upload food diaries or nutrition labels for analysis.",
      );
    } catch (e) {
      _addErrorMessage(
          "Failed to initialize chat. Please check your connection.");
    }
  }

  void _addBotMessage(String content) {
    _addMessage(content, false);
  }

  void _addUserMessage(String content) {
    _addMessage(content, true);
  }

  void _addErrorMessage(String content) {
    _addMessage(content, false, isError: true);
  }

  //Message is added and the respective owner is identified (User or Bot)
  void _addMessage(String content, bool isUser, {bool isError = false}) {
    setState(() {
      _messages.add(ChatMessage(
        content: content,
        isUser: isUser,
        timestamp: DateTime.now(),
        isError: isError,
      ));
    });
    _scrollToBottom();
  }

  //File Upload implementation
  Future<void> _handleFilePick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });

        _addUserMessage("📎 Uploaded: ${result.files.single.name}");
        await _processFile(result.files.single.name);
      }
    } catch (e) {
      _addErrorMessage("Failed to upload file. Please try again.");
    }
  }

  //Handling the File processing So that the Bot can analize it.
  Future<void> _processFile(String fileName) async {
    if (_selectedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _chatBotService.getResponse(
        "Please analyze this file: $fileName",
        file: _selectedFile,
      );
      _addBotMessage(response);
    } catch (e) {
      _addErrorMessage("Failed to process file. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
        _selectedFile = null; // Clear the file after processing
      });
    }
  }

  //User message Submition handling
  Future<void> _handleMessageSubmit(String text) async {
    if (text.trim().isEmpty) return;

    //Clear the message controller to ensure it is empty before adding a message
    _messageController.clear();
    _addUserMessage(text);

    setState(() => _isLoading = true);

    //handle ChatBot Response
    try {
      final response = await _chatBotService.getResponse(text);
      _addBotMessage(response);
    } catch (e) {
      _addErrorMessage("Failed to get response. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSuggestedQuestions(),
          Expanded(
            child: Stack(
              children: [
                _buildMessagesList(),
                if (_isLoading) _buildLoadingIndicator(),
              ],
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('AI Nutrition Assistant',
          style: ThemeConstants.headingStyle.copyWith(color: Colors.white)),
      backgroundColor: ThemeConstants.primaryColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            // Show help dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('How to use', style: ThemeConstants.cardTitleStyle),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Ask questions about nutrition and health\n'
                        '• Upload food diaries or nutrition labels\n'
                        '• Get personalized meal plans\n'
                        '• Calculate BMI and calories\n'
                        '• Analyze your diet',
                        style: ThemeConstants.bodyStyle,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Got it'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSuggestedQuestions() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(
        vertical: ThemeConstants.smallPadding,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedQuestions.length,
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.defaultPadding,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: ThemeConstants.smallPadding),
            child: ActionChip(
              backgroundColor: ThemeConstants.primaryColor.withOpacity(0.1),
              label: Text(
                _suggestedQuestions[index],
                style: ThemeConstants.bodyStyle.copyWith(
                  color: ThemeConstants.primaryColor,
                ),
              ),
              onPressed: () => _handleMessageSubmit(_suggestedQuestions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _MessageBubble(message: _messages[index]);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      bottom: ThemeConstants.defaultPadding,
      left: ThemeConstants.defaultPadding,
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.smallPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeConstants.primaryColor,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text('Processing...'),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: ThemeConstants.defaultPadding,
        right: ThemeConstants.defaultPadding,
        top: ThemeConstants.smallPadding,
        bottom:
            MediaQuery.of(context).padding.bottom + ThemeConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoading ? null : _handleFilePick,
            icon: const Icon(Icons.attach_file),
            color: _isLoading ? Colors.grey : ThemeConstants.primaryColor,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about nutrition, meals, or upload a file...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.defaultBorderRadius,
                  ),
                  borderSide: BorderSide(
                    color: ThemeConstants.primaryColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.defaultBorderRadius,
                  ),
                  borderSide: const BorderSide(
                    color: ThemeConstants.primaryColor,
                  ),
                ),
              ),
              onSubmitted: _handleMessageSubmit,
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: ThemeConstants.smallPadding),
          IconButton(
            onPressed: _isLoading
                ? null
                : () => _handleMessageSubmit(_messageController.text),
            icon: const Icon(Icons.send),
            color: _isLoading ? Colors.grey : ThemeConstants.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: message.isUser ? 64 : 0,
          right: message.isUser ? 0 : 64,
          bottom: ThemeConstants.smallPadding,
        ),
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        decoration: BoxDecoration(
          color: message.isError
              ? ThemeConstants.errorColor.withOpacity(0.1)
              : message.isUser
                  ? ThemeConstants.primaryColor
                  : Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(ThemeConstants.defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: ThemeConstants.bodyStyle.copyWith(
                color: message.isError
                    ? ThemeConstants.errorColor
                    : message.isUser
                        ? Colors.white
                        : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: ThemeConstants.statLabelStyle.copyWith(
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Chat message structure
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final String? fileName;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.fileName,
  });
}
