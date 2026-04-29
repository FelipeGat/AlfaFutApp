import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../shared/brasao_svg.dart';
import '../data/placar.dart';
import '../data/time_partida.dart';
import 'partida_detalhe_page.dart';

class ControlePartidaPage extends ConsumerStatefulWidget {
  const ControlePartidaPage({super.key, required this.partidaId});
  final int partidaId;

  @override
  ConsumerState<ControlePartidaPage> createState() => _ControlePartidaPageState();
}

class _ControlePartidaPageState extends ConsumerState<ControlePartidaPage> {
  Timer? _timer;
  Timer? _polling;

  @override
  void initState() {
    super.initState();
    // Polling a cada 4 segundos
    _polling = Timer.periodic(const Duration(seconds: 4), (_) {
      ref.invalidate(placarProvider(widget.partidaId));
    });
    // Tick local do cronometro a cada 1s (visual)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _polling?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placarAsync = ref.watch(placarProvider(widget.partidaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle ao vivo'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(placarProvider(widget.partidaId)),
          ),
        ],
      ),
      body: placarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Erro: $e'))),
        data: (placar) {
          if (placar.times.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('E preciso sortear os times antes de controlar a partida.', textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _placarResumido(context, placar),
              const SizedBox(height: 16),
              _botoesControle(context, placar),
              const SizedBox(height: 16),
              if (!placar.finalizada) ..._cardsMarcarGol(context, placar),
              const SizedBox(height: 16),
              _eventosRegistrados(context, placar),
            ],
          );
        },
      ),
    );
  }

  Widget _placarResumido(BuildContext context, Placar placar) {
    final tA = placar.timeA!;
    final tB = placar.timeB!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _timeMini(tA, placar.placarA)),
            Column(
              children: [
                const Text('CRONOMETRO', style: TextStyle(fontSize: 11, letterSpacing: 1)),
                Text(
                  placar.tempoFormatado,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
              ],
            ),
            Expanded(child: _timeMini(tB, placar.placarB)),
          ],
        ),
      ),
    );
  }

  Widget _timeMini(TimePartida t, int gols) {
    return Column(
      children: [
        BrasaoSvg(path: t.brasao, size: 56, semanticLabel: t.nome),
        const SizedBox(height: 4),
        Text(t.nome, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('$gols', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, height: 1)),
      ],
    );
  }

  Widget _botoesControle(BuildContext context, Placar placar) {
    final repo = ref.read(partidaRepositoryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Controle do tempo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (placar.finalizada)
              FilledButton.icon(
                onPressed: () => context.push('/partidas/${widget.partidaId}/resultado'),
                icon: const Icon(Icons.emoji_events),
                label: const Text('Ver resultado final'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _executar(() async {
                        if (placar.emAndamento) {
                          await repo.pausar(widget.partidaId);
                        } else {
                          await repo.iniciar(widget.partidaId);
                        }
                      }),
                      style: FilledButton.styleFrom(
                        backgroundColor: placar.emAndamento ? Colors.orange : null,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: Icon(placar.emAndamento ? Icons.pause : Icons.play_arrow),
                      label: Text(placar.emAndamento
                          ? 'Pausar'
                          : (placar.iniciadaEm != null ? 'Retomar' : 'Iniciar')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _confirmarFinalizar(repo),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.flag),
                      label: const Text('Finalizar'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _cardsMarcarGol(BuildContext context, Placar placar) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.sports_soccer, size: 20),
            const SizedBox(width: 8),
            Text('Marcar gol', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
      const SizedBox(height: 8),
      ...placar.times.map((time) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BrasaoSvg(path: time.brasao, size: 56, semanticLabel: time.nome),
                    const SizedBox(height: 4),
                    Text(time.nome, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      decoration: const InputDecoration(labelText: 'Quem fez o gol?'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Nao informar')),
                        ...time.jogadores.map((j) => DropdownMenuItem(value: j.id, child: Text(j.nome))),
                      ],
                      onChanged: (jid) {
                        if (jid != null || time.jogadores.isEmpty) {
                          _registrarGol(time.id, jid);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          )),
    ];
  }

  Widget _eventosRegistrados(BuildContext context, Placar placar) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eventos registrados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (placar.eventos.isEmpty)
              const Text('Nenhum evento ainda. Inicie a partida para comecar.',
                  style: TextStyle(color: Colors.black54)),
            ...placar.eventos.reversed.map((ev) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 50,
                    child: Text("${ev.minuto}'",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500)),
                  ),
                  title: Text(ev.jogadorNome ?? _rotuloEvento(ev.tipo)),
                  subtitle: ev.timeNome != null ? Text(ev.timeNome!) : null,
                  trailing: Text(ev.icone, style: const TextStyle(fontSize: 24)),
                )),
          ],
        ),
      ),
    );
  }

  String _rotuloEvento(String tipo) {
    return switch (tipo) {
      'inicio' => 'Inicio da partida',
      'pausa' => 'Pausa',
      'retomada' => 'Retomada',
      'fim' => 'Fim da partida',
      'gol' => 'Gol',
      'gol_contra' => 'Gol contra',
      _ => tipo,
    };
  }

  Future<void> _executar(Future<void> Function() acao) async {
    try {
      await acao();
      ref.invalidate(placarProvider(widget.partidaId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _registrarGol(int timeId, int? jogadorId) async {
    await _executar(() async {
      await ref.read(partidaRepositoryProvider).registrarGol(
            widget.partidaId,
            timeId: timeId,
            jogadorId: jogadorId,
          );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚽ Gol registrado!')),
      );
    }
  }

  Future<void> _confirmarFinalizar(dynamic repo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar partida?'),
        content: const Text('Esta acao nao pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _executar(() => repo.finalizar(widget.partidaId));
      if (mounted) {
        context.go('/partidas/${widget.partidaId}/resultado');
      }
    }
  }
}
