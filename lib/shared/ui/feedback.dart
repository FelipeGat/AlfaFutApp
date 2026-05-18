import 'package:flutter/material.dart';

import '../../core/error/app_error.dart';

/// Helpers para exibir feedback visual (snackbar, dialog, banner).
class AppFeedback {
  static void sucesso(BuildContext context, String mensagem) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(mensagem)),
        ]),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void erro(BuildContext context, Object e) {
    if (!context.mounted) return;
    final err = e is AppError ? e : AppError.fromException(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(err.mensagem)),
        ]),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void info(BuildContext context, String mensagem) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Confirmacao simples (Cancelar / Confirmar).
  static Future<bool> confirmar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String textoConfirmar = 'Confirmar',
    String textoCancelar = 'Cancelar',
    bool destrutivo = false,
  }) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(textoCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: destrutivo
                ? FilledButton.styleFrom(backgroundColor: Colors.red.shade700)
                : null,
            child: Text(textoConfirmar),
          ),
        ],
      ),
    );
    return r ?? false;
  }
}
