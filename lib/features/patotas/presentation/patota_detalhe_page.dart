import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../partidas/data/partida.dart';

class PatotaDetalhePage extends ConsumerWidget {
  const PatotaDetalhePage({super.key, required this.patotaId});
  final int patotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partidasAsync = ref.watch(partidasPorPatotaProvider(patotaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patota'),
        actions: [
          IconButton(
            tooltip: 'Despesas da patota',
            icon: const Icon(Icons.attach_money),
            onPressed: () => context.push('/patotas/$patotaId/despesas'),
          ),
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(partidasPorPatotaProvider(patotaId)),
          ),
        ],
      ),
      body: partidasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (partidas) {
          final lista = partidas as List<Partida>;
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhuma partida agendada.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = lista[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.sports_soccer),
                  ),
                  title: Text(p.titulo),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(DateFormat("EEE, d 'de' MMM 'as' HH:mm", 'pt_BR').format(p.dataHora.toLocal())),
                      Text('${p.localNome ?? "Local a definir"} • ${p.vagasDisponiveis}/${p.vagasTotal} vagas'),
                    ],
                  ),
                  trailing: _statusChip(context, p),
                  onTap: () => context.push('/partidas/${p.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(BuildContext context, Partida p) {
    if (p.euConfirmei) {
      return const Chip(
        label: Text('Confirmado'),
        backgroundColor: Color(0xFFB9F6CA),
      );
    }
    if (p.euNaListaEspera) {
      return const Chip(
        label: Text('Espera'),
        backgroundColor: Color(0xFFFFF59D),
      );
    }
    return Chip(
      label: Text(p.cheia ? 'Cheia' : 'Vagas'),
      backgroundColor: p.cheia ? const Color(0xFFFFCDD2) : null,
    );
  }
}
