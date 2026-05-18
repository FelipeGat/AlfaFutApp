import 'package:flutter/material.dart';

/// Widget de estado de carregamento padronizado.
class CarregandoView extends StatelessWidget {
  const CarregandoView({super.key, this.mensagem});
  final String? mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (mensagem != null) ...[
            const SizedBox(height: 16),
            Text(mensagem!, style: const TextStyle(color: Colors.black54)),
          ],
        ],
      ),
    );
  }
}

/// Widget de estado de erro com botao de retry.
class ErroView extends StatelessWidget {
  const ErroView({super.key, required this.mensagem, this.onRetry});
  final String mensagem;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de estado vazio padronizado.
class VazioView extends StatelessWidget {
  const VazioView({
    super.key,
    required this.titulo,
    this.descricao,
    this.icone = Icons.inbox_outlined,
    this.acao,
    this.tituloAcao,
  });

  final String titulo;
  final String? descricao;
  final IconData icone;
  final VoidCallback? acao;
  final String? tituloAcao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 72, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (descricao != null) ...[
              const SizedBox(height: 8),
              Text(
                descricao!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            if (acao != null && tituloAcao != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: acao, child: Text(tituloAcao!)),
            ],
          ],
        ),
      ),
    );
  }
}
