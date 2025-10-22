import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bolha de mensagem estilo ChatGPT.
/// - [isUser] alinha e colore a bolha (direita/primária para usuário, esquerda/escura para bot).
/// - [text] conteúdo da mensagem.
/// - [isStreaming] mostra indicador de digitação (três pontinhos animados).
/// - [error] muda estilo para erro.
/// - [avatar] opcional: ícone/avatar compacto.
/// - [time] opcional: horário abaixo da bolha.
class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final bool isStreaming;
  final bool error;
  final Widget? avatar;
  final String? time;
  final EdgeInsetsGeometry padding;
  final double maxWidthFactor;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.text,
    this.isStreaming = false,
    this.error = false,
    this.avatar,
    this.time,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.maxWidthFactor = 0.86,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = error
        ? const Color(0xFF3B1F23)
        : isUser
            ? theme.colorScheme.primary
            : const Color(0xFF26282B); // fundo bot
    final fg = error
        ? const Color(0xFFFFB4C0)
        : isUser
            ? Colors.white
            : Colors.white;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );

    final bubble = Container(
      constraints: BoxConstraints(
        // limita a largura para manter o visual de chat
        maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: error ? Border.all(color: const Color(0xFFFF4D67).withOpacity(.35)) : null,
      ),
      child: GestureDetector(
        onLongPress: () async {
          await Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copiado')),
          );
        },
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(color: fg, height: 1.35),
          child: isStreaming
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(text.isEmpty ? '\u200B' : text)),
                    const SizedBox(width: 8),
                    const _TypingDots(),
                  ],
                )
              : Text(text),
        ),
      ),
    );

    final timeLabel = time == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              time!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          );

    final rowChildren = <Widget>[
      if (!isUser) ...[
        avatar ?? const _MiniAvatar(icon: Icons.smart_toy_rounded),
        const SizedBox(width: 8),
      ],
      Flexible(child: Column(crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [bubble, timeLabel])),
      if (isUser) ...[
        const SizedBox(width: 8),
        avatar ?? const _MiniAvatar(icon: Icons.person_rounded),
      ],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: rowChildren,
      ),
    );
  }
}

/// Avatar circular simples (32x32) para a bolha.
class _MiniAvatar extends StatelessWidget {
  final IconData icon;
  const _MiniAvatar({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF303236),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: Colors.white70),
    );
  }
}

/// Três pontinhos animados (digitando…)
class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 900),
  )..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        int active = ( _c.value * 3 ).floor() % 3; // 0,1,2
        Widget dot(int i) => Opacity(
          opacity: i == active ? 1 : .35,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.5),
            child: CircleAvatar(radius: 3),
          ),
        );
        return Row(children: [dot(0), dot(1), dot(2)]);
      },
    );
  }
}
