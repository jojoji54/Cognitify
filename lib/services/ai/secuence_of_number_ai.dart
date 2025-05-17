import 'dart:convert';
import 'package:cognitify/utils/test_constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecuenceOfNumberAI {
  static final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String apiUrl = "https://api.openai.com/v1/chat/completions";
  static bool debug = true;

  static void log(String message) {
    if (debug) {
      print(message);
    }
  }

  static Future<String> rewriteText(String inputText,
      {String additionalContext = "", String lenguajeContext = ""}) async {
    final String prompt =Constant.prompt;

    try {
      log("Enviando solicitud con prompt: $prompt");

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              "model": "gpt-4",
              "messages": [
                {"role": "system", "content": "Eres un asistente útil."},
                {"role": "user", "content": prompt}
              ],
              "max_tokens": 600,
            }),
          )
          .timeout(const Duration(seconds: 15), onTimeout: () {
            throw Exception("Error: La solicitud excedió el tiempo de espera.");
          });

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);

        final rewrittenText = data['choices']?[0]?['message']?['content']?.trim();
        if (rewrittenText != null) {
               log("Respuesta: $rewrittenText");
          return rewrittenText;
        } else {
          return "Error: Respuesta vacía de OpenAI.";
        }
      } else {
        final errorData = jsonDecode(response.body);
        log("Error en OpenAI: ${jsonEncode(errorData)}");
        return "Error: ${errorData['error']['message'] ?? 'No se pudo procesar la solicitud.'}";
      }
    } catch (e) {
      log("Excepción en rewriteText: $e");
      return "Error al procesar el texto.";
    }
  }
}