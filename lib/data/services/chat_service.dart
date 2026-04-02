import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  late final GenerativeModel _model;

  ChatService()
    : _model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: 'AIzaSyAZEVlMkSYquXUbG0b7V6SVHCxZu6mRYW0',
      );

  Future<String> getNutritionAdvice(String userMessage) async {
    try {
      final prompt =
          "You are a professional nutritionist. Answer the following question briefly and clearly: $userMessage";

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? "Sorry, I could not find";
    } catch (e) {
      return "Error: $e";
    }
  }
}
