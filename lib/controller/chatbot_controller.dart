import 'package:cognai/models/chatbot_model.dart';
import 'package:cognai/services/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatbotControllerProvider =
    StateNotifierProvider<ChatbotController, List<ChatbotModel>>((ref) {
      return ChatbotController(ref);
    });

class ChatbotController extends StateNotifier<List<ChatbotModel>> {
  ChatbotController(this.ref) : super([]);

  final ApiService _service = ApiService();
  final Ref ref;

  void addMessage(ChatbotModel msg) {
    state = [...state, msg];
  }

  Future<String?> postMessage({required ChatbotModel message}) async {
    try {
      if (message.query == null) return "Digite uma mensagem";

      final response = await _service.postMessage(message);

      state = [...state, response];
      return null;
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      return 'Erro interno';
    }
  }
}
