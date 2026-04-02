import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  final double bmi;
  final String name;
  const ChatScreen({super.key, required this.bmi, required this.name});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "role": "ai",
      "message":
          "Hello! I am your AI Diet Assistant. How can I help you today?",
    },
  ];
  late final GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    final apiKey = dotenv.env['API_KEY'];
    super.initState();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API_KEY not found in .env");
    }

    _model = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: apiKey);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    String userQuery = _controller.text.trim();
    if (userQuery.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "message": userQuery});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    String status = "";
    if (widget.bmi < 18.5)
      status = "Underweight";
    else if (widget.bmi < 24.9)
      status = "Normal weight";
    else if (widget.bmi < 29.9)
      status = "Overweight";
    else
      status = "Obese";

    String personalizedPrompt =
        """
  You are a professional AI Dietitian. 
  User Name: ${widget.name}
  User BMI: ${widget.bmi.toStringAsFixed(1)} (Status: $status)
  User's Question: $userQuery
  """;

    try {
      final content = [Content.text(personalizedPrompt)];
      final response = await _model.generateContent(content);
      final aiResponse = response.text ?? "Sorry, I could not give the answer";

      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "message": aiResponse});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "ai", "message": "Oops!!!. Please Try Again"});
          _isLoading = false;
        });
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("AI Diet Assistant"),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: const Icon(Icons.psychology_outlined),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isAI = _messages[index]['role'] == 'ai';
                return _buildMessageBubble(isAI, _messages[index]['message']!);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isAI, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: isAI
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isAI ? Colors.white : Colors.green[700],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: Radius.circular(isAI ? 0 : 15),
                bottomRight: Radius.circular(isAI ? 15 : 0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: isAI
                ? MarkdownBody(
                    data: message,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  )
                : Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
          const SizedBox(height: 2),
          Text(
            isAI ? "AI Assistant" : "You",
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ask about your diet...",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green[700],
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
