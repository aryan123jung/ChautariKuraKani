import 'dart:convert';
import 'package:chautari_kurakani/features/dashboard/data/datasources/api.dart';
import 'package:http/http.dart' as http;

class AiService {
  final String apiKey = Api.groqApiKey;

  Future<String> sendMessage(String userMessage) async {
    final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");

    final systemPrompt =
        "You are a fun, friendly, humorous chatbot for a social media app. "
        "Always respond casually, with small jokes, emojis, and a positive vibe. "
        "Keep answers short and fun.";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "llama-3.1-8b-instant",
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": userMessage}
        ],
        "max_tokens": 150,
        "temperature": 0.9
      }),
    );

    if (response.statusCode == 503) {
      await Future.delayed(const Duration(seconds: 1));
      return sendMessage(userMessage);
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      return "Error: ${response.statusCode} → ${response.body}";
    }
  }
}
