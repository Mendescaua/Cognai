import 'package:flutter/material.dart';

void FloatingMessage(BuildContext context, String message, String type, int seconds) {
  Color bgColor;
  IconData icon;
  String title;

  switch (type.toLowerCase()) {
    case 'success':
      bgColor = Colors.green.shade100;
      icon = Icons.check_circle;
      title = 'Sucesso';
      break;
    case 'warning':
      bgColor = Colors.orange.shade100;
      icon = Icons.warning_amber_rounded;
      title = 'Aviso';
      break;
    case 'error':
      bgColor = Colors.red.shade100;
      icon = Icons.error_outline;
      title = 'Erro';
      break;
    case 'info':
    default:
      bgColor = Colors.blue.shade100;
      icon = Icons.info_outline;
      title = 'Informação';
  }

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: seconds),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.black54, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: const Icon(Icons.close, color: Colors.black54),
            ),
          ],
        ),
      ),
    ),
  );
}
