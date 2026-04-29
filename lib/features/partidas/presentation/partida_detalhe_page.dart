import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../shared/brasao_svg.dart';
import '../data/partida.dart';
import '../data/placar.dart';

final partidaProvider = FutureProvider.autoDispose.family<Partida, int>((ref, id) async {
  return ref.read(partidaRepositoryProvider).obter(id);
});

final placarProvider = FutureProvider.autoDispose.family<Placar, int>((ref, id) async {
  return ref.read(partidaRepositoryProvider).obterPlacar(id);
});

class PartidaDetalhePage extends ConsumerWidget {
  const PartidaDetalhePage({super.key, required this.partidaId});
  final int partidaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partidaAsync = ref.watch(partidaProvider(partidaId));
    final placarAsync = ref.watch(placarProvider(partidaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Partida')),
      body: partidaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (p) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(partidaProvider(partidaId));
            ref.invalidate(placarProvider(partidaId));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cabecalho com placar (se ja sortearam times)
              placarAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (placar) {
                  if (placar.times.length < 2) return const SizedBox();
                  return _PlacarCard(placar: placar);
                },
              ),

              const SizedBox(height: 12),
              Text(p.titulo, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                DateFormat("EEEE, d 'de' MMMM 'as' HH:mm", 'pt_BR').format(p.dataHora.toLocal()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              if (p.descricao != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(p.descricao!),
                  ),
                ),
              const SizedBox(height: 12),

              // Botoes do placar (se ja sortearam)
              placarAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (placar) {
                  if (placar.times.length < 2) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (!placar.finalizada)
                          FilledButton.icon(
                            onPressed: () => context.push('/partidas/$partidaId/controle'),
                            icon: const Icon(Icons.sports_soccer),
                            label: const Text('Controle ao vivo'),
                          ),
                        if (placar.finalizada)
                          FilledButton.icon(
                            onPressed: () => context.push('/partidas/$partidaId/resultado'),
                            icon: const Icon(Icons.emoji_events),
                            label: const Text('Resultado'),
                          ),
                      ],
                    ),
                  );
                },
              ),

              _info('Local', p.localNome ?? 'A definir', icone: Icons.place),
              if (p.localEndereco != null) _info('Endereco', p.localEndereco!, icone: Icons.map),
              if (p.localAcessivel == true)
                _info('Acessibilidade', 'Local acessivel para cadeirantes', icone: Icons.accessible_forward),
              _info('Duracao', '${p.duracaoMinutos} min', icone: Icons.timer),
              _info('Vagas', '${p.vagasDisponiveis}/${p.vagasTotal}', icone: Icons.group),
              _info(
                'Valor por jogador',
                'R\$ ${p.valorIndividual.toStringAsFixed(2)}',
                icone: Icons.attach_money,
              ),
              const SizedBox(height: 24),
              if (p.euConfirmei)
                _statusBox(context, 'Voce esta confirmado nesta partida.', Colors.green)
              else if (p.euNaListaEspera)
                _statusBox(context, 'Voce esta na lista de espera.', Colors.orange),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  await ref.read(partidaRepositoryProvider).confirmar(p.id);
                  ref.invalidate(partidaProvider(partidaId));
                  ref.invalidate(placarProvider(partidaId));
                },
                icon: const Icon(Icons.check),
                label: Text(p.euConfirmei ? 'Manter confirmacao' : 'Confirmar presenca'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(partidaRepositoryProvider).recusar(p.id);
                  ref.invalidate(partidaProvider(partidaId));
                  ref.invalidate(placarProvider(partidaId));
                },
                icon: const Icon(Icons.close),
                label: const Text('Nao vou'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String rotulo, String valor, {IconData? icone}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icone != null) Padding(padding: const EdgeInsets.only(right: 12), child: Icon(icone)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(valor, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBox(BuildContext context, String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, color: cor),
        const SizedBox(width: 8),
        Expanded(child: Text(texto)),
      ]),
    );
  }
}

class _PlacarCard extends StatelessWidget {
  const _PlacarCard({required this.placar});
  final Placar placar;

  @override
  Widget build(BuildContext context) {
    final tA = placar.timeA!;
    final tB = placar.timeB!;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status
            _StatusBadge(placar: placar),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _TimeColuna(nome: tA.nome, brasao: tA.brasao, gols: placar.placarA)),
                Column(
                  children: [
                    Text(
                      placar.tempoFormatado,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    const Text('cronometro', style: TextStyle(fontSize: 10, letterSpacing: 1)),
                  ],
                ),
                Expanded(child: _TimeColuna(nome: tB.nome, brasao: tB.brasao, gols: placar.placarB)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeColuna extends StatelessWidget {
  const _TimeColuna({required this.nome, required this.brasao, required this.gols});
  final String nome;
  final String? brasao;
  final int gols;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BrasaoSvg(path: brasao, size: 64, semanticLabel: nome),
        const SizedBox(height: 4),
        Text(nome, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('$gols', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, height: 1)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.placar});
  final Placar placar;

  @override
  Widget build(BuildContext context) {
    final (cor, texto, icone) = placar.finalizada
        ? (Colors.grey, 'FINALIZADA', Icons.flag)
        : placar.pausada
            ? (Colors.orange, 'PAUSADA', Icons.pause)
            : placar.emAndamento
                ? (Colors.red, 'AO VIVO', Icons.fiber_manual_record)
                : (Colors.blue, 'AGUARDANDO INICIO', Icons.schedule);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(texto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
        ],
      ),
    );
  }
}
