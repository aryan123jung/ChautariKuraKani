// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AIService {
//   final String apiKey = "AIzaSyDbDKkEKNSOPvo5IXPszDec6SbV5xofOUA";

//   Future<String> sendMessage(String userMessage) async {
//     // final url = Uri.parse("https://api.openai.com/v1/chat/completions");
//     final url = Uri.parse(
//         "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
//     );

//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         // "Authorization": "Bearer $apiKey",
//       },
//       body: jsonEncode({
//         "model": "gpt-4o-mini", 
//         "messages": [
//           {"role": "user", "content": userMessage}
//         ]
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       return data["choices"][0]["message"]["content"];
//     } else {
//       return "Error: ${response.body}";
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  final String apiKey = "AIzaSyDCKg408QseQDYanvapJvTHFPoCwWzkZ_k";

  Future<String> sendMessage(String message, {int retries = 1}) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "You are a fun, friendly, funny chatbot. Always reply with humor, small jokes, and positive energy. Keep answers short, helpful, and entertaining."
              }
            ]
          },
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    // SUCCESS → return AI reply
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    }

    // MODEL OVERLOADED → retry once
    if (response.statusCode == 503 && retries > 0) {
    await Future.delayed(const Duration(seconds: 2));
    return await sendMessage(message, retries: retries - 1);
  }

    // OTHER ERRORS
    return "Error: ${response.statusCode} → ${response.body}";
  }
}
