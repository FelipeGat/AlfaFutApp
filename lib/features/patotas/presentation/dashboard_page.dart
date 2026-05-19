import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../shared/brasao_svg.dart';
import '../../../shared/ui/estados.dart';
import '../../../shared/ui/feedback.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).usuario;
    final patotasAsync = ref.watch(patotasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: const Text('A', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            const Text('AlfaFut'),
          ],
        ),
        actions: [
          if (usuario?.isAdmin == true)
            IconButton(
              tooltip: 'Painel administrativo',
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => context.push('/admin'),
            ),
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/perfil'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(patotasProvider),
        child: patotasAsync.when(
          loading: () => const CarregandoView(),
          error: (e, _) => ErroView(
            mensagem: 'Nao foi possivel carregar suas turmas.',
            onRetry: () => ref.invalidate(patotasProvider),
          ),
          data: (patotas) {
            final lista = patotas;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Saudacao
                Text(
                  'Ola, ${usuario?.nomeExibicao ?? "jogador"}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Pronto para a proxima pelada?',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),

                // Banner admin (so para administradores globais)
                if (usuario?.isAdmin == true) ...[
                  Card(
                    color: Colors.orange.shade50,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.shield),
                      ),
                      title: const Text('Painel administrativo', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Acesso global a todas as turmas, partidas e usuarios'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/admin'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Cards de resumo
                Row(
                  children: [
                    Expanded(child: _resumoCard(context, 'Turmas', '${lista.length}', Icons.groups)),
                    const SizedBox(width: 8),
                    Expanded(child: _resumoCard(context, 'Membros', '${lista.fold<int>(0, (s, p) => s + (p.totalMembros ?? 0))}', Icons.people)),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de turmas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Text('Minhas turmas', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _entrarPorCodigo(context, ref),
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Entrar com codigo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                if (lista.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.sports_soccer, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text('Nenhuma turma ainda', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text(
                            'Crie sua primeira turma ou entre em uma com codigo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...lista.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: p.brasao != null
                                ? BrasaoSvg(path: p.brasao, size: 48, semanticLabel: p.nome)
                                : CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    child: const Icon(Icons.groups),
                                  ),
                            title: Text(p.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${p.cidade ?? "Sem cidade"} • ${p.totalMembros ?? "?"} membros'),
                            trailing: Chip(label: Text('${p.jogadoresPorTime}x${p.jogadoresPorTime}')),
                            onTap: () => context.push('/patotas/${p.id}'),
                          ),
                        ),
                      )),

                const SizedBox(height: 80), // espaco pro FAB
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/patotas/nova'),
        icon: const Icon(Icons.add),
        label: const Text('Nova turma'),
      ),
    );
  }

  Widget _resumoCard(BuildContext context, String label, String valor, IconData icone) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(valor, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _entrarPorCodigo(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Entrar com codigo de convite'),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Codigo de 8 caracteres'),
          maxLength: 8,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(patotaRepositoryProvider).entrarPorCodigo(ctrl.text.trim().toUpperCase());
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ref.invalidate(patotasProvider);
                  AppFeedback.sucesso(ctx, 'Voce entrou na turma!');
                }
              } catch (e) {
                if (ctx.mounted) AppFeedback.erro(ctx, e);
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }
}
