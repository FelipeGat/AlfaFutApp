import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../shared/brasao_svg.dart';
import '../../../shared/ui/estados.dart';

class PainelAdminPage extends ConsumerWidget {
  const PainelAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).usuario;
    if (usuario == null || !usuario.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso negado')),
        body: const Center(child: Text('Apenas administradores.')),
      );
    }

    final resumoAsync = ref.watch(adminResumoProvider);
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings, size: 22),
            SizedBox(width: 8),
            Text('Painel administrativo'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminResumoProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminResumoProvider),
        child: resumoAsync.when(
          loading: () => const CarregandoView(mensagem: 'Carregando estatisticas...'),
          error: (e, _) => ErroView(
            mensagem: e.toString(),
            onRetry: () => ref.invalidate(adminResumoProvider),
          ),
          data: (r) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.shield, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voce e administrador global',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              usuario.email,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Visao geral', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),

              // Cards de estatisticas
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.5,
                children: [
                  _stat(context, '${r.totalUsuarios}', 'Usuarios', Icons.people, Colors.blue),
                  _stat(context, '${r.totalPatotas}', 'Turmas', Icons.groups, Colors.green),
                  _stat(context, '${r.partidasEmAndamento}', 'Ao vivo', Icons.live_tv, Colors.red),
                  _stat(context, '${r.partidasAgendadas}', 'Agendadas', Icons.schedule, Colors.orange),
                  _stat(context, '${r.partidasFinalizadas}', 'Finalizadas', Icons.flag, Colors.grey),
                  _stat(context, '${r.despesasAbertas}', 'Despesas abertas', Icons.receipt_long, Colors.deepOrange),
                ],
              ),

              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: const Text('Valor total em despesas'),
                  trailing: Text(
                    formatador.format(r.valorTotalDespesas),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text('Gerenciar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),

              _menuItem(context, 'Todas as turmas', '${r.totalPatotas} turmas no sistema', Icons.groups, () => context.push('/admin/patotas')),
              _menuItem(context, 'Partidas ao vivo e agendadas', 'Acompanhe placar e cronometro', Icons.live_tv, () => context.push('/admin/partidas')),
              _menuItem(context, 'Todos os usuarios', '${r.totalUsuarios} cadastrados (${r.totalAdmins} admin)', Icons.people, () => context.push('/admin/usuarios')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String valor, String label, IconData icone, Color cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icone, color: cor, size: 20),
                const Spacer(),
              ],
            ),
            Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String titulo, String subtitulo, IconData icone, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: Icon(icone),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// =============================================================
// Sub-pagina: Todas as turmas
// =============================================================

final adminPatotasProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(adminRepositoryProvider).patotas();
});

class AdminPatotasPage extends ConsumerWidget {
  const AdminPatotasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patotasAsync = ref.watch(adminPatotasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as turmas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminPatotasProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminPatotasProvider),
        child: patotasAsync.when(
          loading: () => const CarregandoView(),
          error: (e, _) => ErroView(mensagem: e.toString(), onRetry: () => ref.invalidate(adminPatotasProvider)),
          data: (lista) {
            if (lista.isEmpty) {
              return const VazioView(icone: Icons.groups_outlined, titulo: 'Nenhuma turma cadastrada');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final p = lista[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: p.brasao != null
                        ? BrasaoSvg(path: p.brasao, size: 48, semanticLabel: p.nome)
                        : const CircleAvatar(child: Icon(Icons.groups)),
                    title: Text(p.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${p.cidade ?? "-"} • ${p.totalMembros ?? 0} membros'),
                    trailing: Chip(label: Text('${p.jogadoresPorTime}x${p.jogadoresPorTime}')),
                    onTap: () => context.push('/patotas/${p.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// =============================================================
// Sub-pagina: Partidas ao vivo / agendadas
// =============================================================

final adminPartidasProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(adminRepositoryProvider).partidasAtivas();
});

class AdminPartidasPage extends ConsumerWidget {
  const AdminPartidasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partidasAsync = ref.watch(adminPartidasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidas ativas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminPartidasProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminPartidasProvider),
        child: partidasAsync.when(
          loading: () => const CarregandoView(),
          error: (e, _) => ErroView(mensagem: e.toString(), onRetry: () => ref.invalidate(adminPartidasProvider)),
          data: (lista) {
            if (lista.isEmpty) {
              return const VazioView(
                icone: Icons.sports_soccer,
                titulo: 'Nenhuma partida ativa',
                descricao: 'Nao ha partidas em andamento ou agendadas para hoje.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final p = lista[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: p.status == 'em_andamento' ? Colors.red.shade100 : Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: p.status == 'em_andamento' ? Colors.red.shade700 : Theme.of(context).colorScheme.onPrimaryContainer,
                      child: Icon(p.status == 'em_andamento' ? Icons.fiber_manual_record : Icons.sports_soccer),
                    ),
                    title: Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(DateFormat("dd/MM HH:mm").format(p.dataHora.toLocal())),
                        Text(p.localNome ?? 'Local a definir', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: p.status == 'em_andamento'
                        ? const Chip(label: Text('AO VIVO'), backgroundColor: Color(0xFFFFCDD2))
                        : Chip(label: Text(p.status.toUpperCase())),
                    onTap: () => context.push('/partidas/${p.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// =============================================================
// Sub-pagina: Usuarios
// =============================================================

final adminUsuariosProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(adminRepositoryProvider).usuarios();
});

class AdminUsuariosPage extends ConsumerWidget {
  const AdminUsuariosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(adminUsuariosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminUsuariosProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminUsuariosProvider),
        child: usuariosAsync.when(
          loading: () => const CarregandoView(),
          error: (e, _) => ErroView(mensagem: e.toString(), onRetry: () => ref.invalidate(adminUsuariosProvider)),
          data: (lista) {
            if (lista.isEmpty) {
              return const VazioView(icone: Icons.people_outline, titulo: 'Nenhum usuario');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final u = lista[i];
                final inicial = u.nomeExibicao.isNotEmpty ? u.nomeExibicao.substring(0, 1).toUpperCase() : '?';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: u.isAdmin ? Colors.orange.shade100 : Theme.of(context).colorScheme.primary,
                    foregroundColor: u.isAdmin ? Colors.orange.shade900 : Theme.of(context).colorScheme.onPrimary,
                    child: Text(inicial, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Row(
                    children: [
                      Text(u.nomeExibicao, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (u.isAdmin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(4)),
                          child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(u.email, style: const TextStyle(fontSize: 12)),
                  trailing: u.posicaoPreferida != null
                      ? Chip(label: Text(u.posicaoPreferida!.toUpperCase(), style: const TextStyle(fontSize: 10)))
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
