import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  late final GenerativeModel _model;

  ChatService() {
    final apiKey = dotenv.env['API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API_KEY not found in .env");
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // stable model
      apiKey: apiKey, // from .env
    );
  }

  Future<String> getNutritionAdvice(String userMessage) async {
    try {
      final prompt =
          "You are a professional nutritionist. Answer the following question briefly and clearly: $userMessage";

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? "Sorry, I could not find an answer.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }
}
