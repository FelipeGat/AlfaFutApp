import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../shared/brasao_svg.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).usuario;
    final patotasAsync = ref.watch(patotasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ola, ${usuario?.nomeExibicao ?? ""}'),
        actions: [
          IconButton(
            tooltip: 'Acessibilidade',
            icon: const Icon(Icons.accessibility_new),
            onPressed: () => context.push('/acessibilidade'),
          ),
          IconButton(
            tooltip: 'Sair da conta',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).sair();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(patotasProvider),
        child: patotasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Nao foi possivel carregar suas turmas.\n$e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
          data: (patotas) {
            if (patotas.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 48),
                  Icon(Icons.sports_soccer, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Nenhuma turma ainda',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie sua primeira turma ou entre em uma usando codigo de convite.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/patotas/nova'),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar turma'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _entrarPorCodigo(context, ref),
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar com codigo'),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: patotas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = patotas[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: p.brasao != null
                        ? BrasaoSvg(path: p.brasao, size: 48, semanticLabel: p.nome)
                        : CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            child: const Icon(Icons.groups),
                          ),
                    title: Text(p.nome, style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Text(
                      '${p.cidade ?? "Sem cidade"} • ${p.totalMembros ?? "?"} membros',
                    ),
                    trailing: Chip(
                      label: Text('${p.jogadoresPorTime}x${p.jogadoresPorTime}'),
                    ),
                    onTap: () => context.push('/patotas/${p.id}'),
                  ),
                );
              },
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

  Future<void> _entrarPorCodigo(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Entrar com codigo de convite'),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Codigo'),
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
                }
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Codigo invalido.')),
                  );
                }
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }
}
