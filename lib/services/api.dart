import 'dart:convert';
import 'package:cognai/core/config.dart';
import 'package:cognai/models/chatbot_model.dart';
import 'package:cognai/services/token_api.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final AuthService _authService = AuthService(); // instância interna

  final baseUrl = BASE_URL;

   Future<ChatbotModel> postMessage(ChatbotModel message) async {
    String? token = await _authService.getAccessToken();

    var response = await http.post(
      Uri.parse('$baseUrl/cognai/').replace(
            queryParameters: message.toJson(),
          ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // Se o token tiver expirado, tenta renovar
    if (response.statusCode == 401) {
      bool refreshed = await _authService.generateAccessToken();
      if (refreshed) {
        token = await _authService.getAccessToken();
        response = await http.post(
          Uri.parse('$baseUrl/cognai/').replace(
            queryParameters: message.toJson(),
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return ChatbotModel.fromJson(data);
    } else {
      throw Exception(
        'Erro ao gerar resposta: ${response.statusCode} -> ${response.body}',
      );
    }
  }


  // Future<List<ChatbotModel>> getMessage(String userId) async {
  //   String? token = await _authService.getAccessToken();

  //   Future<http.Response> _doGet(String? t) {
  //     return http.get(
  //       Uri.parse('$baseUrl/users/$userId'),
  //       headers: {
  //         'Authorization': 'Bearer $t',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //   }

  //   var response = await _doGet(token);

  //   if (response.statusCode == 401) {
  //     final refreshed = await _authService.generateAccessToken();
  //     if (refreshed) {
  //       token = await _authService.getAccessToken();
  //       response = await _doGet(token);
  //     }
  //   }

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //     return [ChatbotModel.fromJson(data)]; // retorna uma lista com 1 usuário
  //   } else {
  //     throw Exception('Erro ao carregar usuario: ${response.statusCode}');
  //   }
  // }
}