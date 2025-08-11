import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConst {
  ApiConst._();

  static String baseUrl = dotenv.env['BASE_URL'] ?? '';
  static String deepgramBaseUrl = dotenv.env['DEEPGRAM_BASE_URL'] ?? 'https://api.deepgram.com/v1/listen';
  static String groqBaseUrl = dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1/chat/completions';
  static String deepgramApiKey = dotenv.env['DEEPGRAM_API_KEY'] ?? '';
  static String groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
}
