import 'dart:convert';
import 'package:cognai/core/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';

  final String baseUrl = BASE_URL;
  final String apiKey = API_KEY;

  AuthService();

  /// Gera um novo access token usando a API Key
  Future<bool> generateAccessToken() async {
    try {
      var headers = {'ApiKey': apiKey};
      var request = http.Request('POST', Uri.parse('$baseUrl/login/'));
      request.headers.addAll(headers);

      var response = await request.send();
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        String token = data['access_token'];

        // Remove "Bearer " caso venha na resposta
        if (token.startsWith('Bearer ')) {
          token = token.substring(7);
        }

        await saveAccessToken(token);
        return true;
      } else {
        print('Erro ao gerar token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception generateAccessToken: $e');
      return false;
    }
  }

  /// Salva access token de forma segura
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Lê access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Limpa access token (logout)
  Future<void> clearAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Header Authorization padrão
  Future<Map<String, String>> _getAuthHeader() async {
    String? token = await getAccessToken();

    if (token == null) {
      bool success = await generateAccessToken();
      if (success) {
        token = await getAccessToken();
      } else {
        throw Exception("Não foi possível gerar o token");
      }
    }

    return {'Authorization': 'Bearer $token'};
  }

  /// Faz requisição GET protegida, renova token se necessário
  Future<http.Response> get(String path) async {
    Map<String, String> headers = await _getAuthHeader();

    var response = await http.get(Uri.parse('$baseUrl$path'), headers: headers);

    if (response.statusCode == 401) {
      bool success = await generateAccessToken();
      if (success) {
        headers = await _getAuthHeader();
        response = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
      }
    }

    return response;
  }

  /// Faz requisição POST protegida, renova token se necessário
  Future<http.Response> post(String path, {Map<String, String>? extraHeaders, Object? body}) async {
    Map<String, String> headers = await _getAuthHeader();
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    var response = await http.post(Uri.parse('$baseUrl$path'), headers: headers, body: body);

    if (response.statusCode == 401) {
      bool success = await generateAccessToken();
      if (success) {
        headers = await _getAuthHeader();
        if (extraHeaders != null) headers.addAll(extraHeaders);
        response = await http.post(Uri.parse('$baseUrl$path'), headers: headers, body: body);
      }
    }

    return response;
  }
}