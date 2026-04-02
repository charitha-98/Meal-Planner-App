import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  final GenerativeModel _model;

  ChatService()
    : _model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: '${{ secrets.API_KEY }}',
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
