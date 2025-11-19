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

  Future<String> sendMessage(String message) async {
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
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      return "Error: ${response.statusCode} → ${response.body}";
    }
  }
}