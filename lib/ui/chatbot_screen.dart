import 'package:cognai/components/ChatBubble.dart';
import 'package:cognai/components/FloatingMessage.dart';
import 'package:cognai/controller/chatbot_controller.dart';
import 'package:cognai/models/chatbot_model.dart';
import 'package:cognai/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BotScreen extends ConsumerStatefulWidget {
  const BotScreen({super.key});
  @override
  ConsumerState<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends ConsumerState<BotScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool loading = false;

 Future<void> onPost() async {
  final bot = ref.read(chatbotControllerProvider.notifier);
  if (loading) return;

  final text = _input.text.trim();
  if (text.isEmpty) return;

  // 👇 Adiciona a pergunta do usuário antes de enviar
  bot.addMessage(ChatbotModel(query: text));

  setState(() => loading = true);

  final response = await bot.postMessage(
    message: ChatbotModel(query: text),
  );

  setState(() => loading = false);

  // auto-scroll pro final depois de atualizar a lista
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  if (response != null) {
    FloatingMessage(context, response, 'error', 2);
  }
}


  @override
  Widget build(BuildContext context) {
    final _messages = ref.watch(chatbotControllerProvider);
    return Container(
      decoration: const BoxDecoration(color: AppTheme.backgroundColor),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pushNamed('/splash');
            },
          ),
          titleSpacing: 0,
          title: Row(
            children: const [
              Text(
                'Cognai',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Lista de mensagens
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final msg = _messages[i];

                    // Supondo que ChatbotModel tenha `query` (usuário) e `response` (bot).
                    final hasUser = (msg.query != null && msg.query.toString().trim().isNotEmpty);
                    final hasBot  = (msg.response != null && msg.response.toString().trim().isNotEmpty);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hasUser)
                          ChatBubble(
                            isUser: true,
                            text: msg.query ?? '',
                            time: DateTime.now().toString(),
                          ),
                        if (hasBot) ...[
                          const SizedBox(height: 6),
                          ChatBubble(
                            isUser: false,
                            text: msg.response ?? '',
                            time: DateTime.now().toString(),
                          ),
                        ],
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),

              // Barra de entrada
              _InputBar(
                controller: _input,
                onSend: () {
                  onPost();
                  _input.clear();
                },
                onMic: () {
                  // microfone / STT se quiser
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMic;
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _MiniCircleButton(
            icon: Icons.add_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.borderColor),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Ask Cognai',
                        hintStyle: TextStyle(color: Colors.white70),
                        isCollapsed: true,
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MiniCircleButton(
            icon: Icons.graphic_eq_rounded,
            onTap: onMic,
          ),
        ],
      ),
    );
  }
}

class _MiniCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.borderColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
