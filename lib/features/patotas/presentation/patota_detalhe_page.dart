import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../shared/ui/estados.dart';
import '../../../shared/ui/feedback.dart';
import '../../partidas/data/partida.dart';

class PatotaDetalhePage extends ConsumerWidget {
  const PatotaDetalhePage({super.key, required this.patotaId});
  final int patotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partidasAsync = ref.watch(partidasPorPatotaProvider(patotaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turma'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) => _acaoMenu(context, ref, v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'mural', child: ListTile(leading: Icon(Icons.forum), title: Text('Mural'), dense: true)),
              PopupMenuItem(value: 'despesas', child: ListTile(leading: Icon(Icons.attach_money), title: Text('Despesas'), dense: true)),
              PopupMenuDivider(),
              PopupMenuItem(value: 'sair', child: ListTile(leading: Icon(Icons.exit_to_app, color: Colors.red), title: Text('Sair da turma'), dense: true)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(partidasPorPatotaProvider(patotaId)),
        child: partidasAsync.when(
          loading: () => const CarregandoView(),
          error: (e, _) => ErroView(
            mensagem: e.toString(),
            onRetry: () => ref.invalidate(partidasPorPatotaProvider(patotaId)),
          ),
          data: (partidas) {
            final lista = partidas as List<Partida>;
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Atalhos rapidos
                Row(
                  children: [
                    Expanded(child: _atalho(context, '💬 Mural', Icons.forum_outlined, () => context.push('/patotas/$patotaId/mural'))),
                    const SizedBox(width: 8),
                    Expanded(child: _atalho(context, '💰 Despesas', Icons.attach_money, () => context.push('/patotas/$patotaId/despesas'))),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Proximas partidas', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                if (lista.isEmpty)
                  const VazioView(
                    icone: Icons.sports_soccer,
                    titulo: 'Nenhuma partida agendada',
                    descricao: 'Quando uma partida for criada, ela aparece aqui.',
                  )
                else
                  ...lista.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PartidaCard(partida: p),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _atalho(BuildContext context, String titulo, IconData icone, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icone, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acaoMenu(BuildContext context, WidgetRef ref, String acao) async {
    if (acao == 'mural') {
      context.push('/patotas/$patotaId/mural');
    } else if (acao == 'despesas') {
      context.push('/patotas/$patotaId/despesas');
    } else if (acao == 'sair') {
      final ok = await AppFeedback.confirmar(
        context,
        titulo: 'Sair da turma?',
        mensagem: 'Voce nao recebera mais avisos desta turma. Pode entrar de novo usando o codigo de convite.',
        textoConfirmar: 'Sair',
        destrutivo: true,
      );
      if (!ok) return;
      try {
        await ref.read(patotaRepositoryProvider).sair(patotaId);
        ref.invalidate(patotasProvider);
        if (context.mounted) {
          AppFeedback.sucesso(context, 'Voce saiu da turma.');
          context.pop();
        }
      } catch (e) {
        if (context.mounted) AppFeedback.erro(context, e);
      }
    }
  }
}

class _PartidaCard extends StatelessWidget {
  const _PartidaCard({required this.partida});
  final Partida partida;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: const Icon(Icons.sports_soccer),
        ),
        title: Text(partida.titulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(DateFormat("EEE, d 'de' MMM 'as' HH:mm", 'pt_BR').format(partida.dataHora.toLocal())),
            Text('${partida.localNome ?? "Local a definir"} • ${partida.vagasDisponiveis}/${partida.vagasTotal} vagas',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: _statusChip(partida),
        onTap: () => GoRouter.of(context).push('/partidas/${partida.id}'),
      ),
    );
  }

  Widget _statusChip(Partida p) {
    if (p.euConfirmei) return const Chip(label: Text('Confirmado'), backgroundColor: Color(0xFFB9F6CA));
    if (p.euNaListaEspera) return const Chip(label: Text('Espera'), backgroundColor: Color(0xFFFFF59D));
    return Chip(label: Text(p.cheia ? 'Cheia' : 'Vagas'), backgroundColor: p.cheia ? const Color(0xFFFFCDD2) : null);
  }
}
