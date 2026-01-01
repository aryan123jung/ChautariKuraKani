import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
}
