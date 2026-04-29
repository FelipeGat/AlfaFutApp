import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/brasao_svg.dart';
import 'partida_detalhe_page.dart';

class ResultadoPage extends ConsumerWidget {
  const ResultadoPage({super.key, required this.partidaId});
  final int partidaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placarAsync = ref.watch(placarProvider(partidaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: placarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (placar) {
          if (placar.times.length < 2) {
            return const Center(child: Text('Dados insuficientes.'));
          }
          final tA = placar.timeA!;
          final tB = placar.timeB!;
          String? vencedorNome;
          if (placar.placarA > placar.placarB) vencedorNome = tA.nome;
          else if (placar.placarB > placar.placarA) vencedorNome = tB.nome;

          final totalGols = placar.placarA + placar.placarB;
          final artilharia = placar.artilharia;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Placar final
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('PLACAR FINAL',
                          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                BrasaoSvg(path: tA.brasao, size: 88, semanticLabel: tA.nome),
                                const SizedBox(height: 6),
                                Text(tA.nome, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('${placar.placarA}', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, height: 1)),
                              ],
                            ),
                          ),
                          const Text('×', style: TextStyle(fontSize: 28, color: Colors.black38)),
                          Expanded(
                            child: Column(
                              children: [
                                BrasaoSvg(path: tB.brasao, size: 88, semanticLabel: tB.nome),
                                const SizedBox(height: 6),
                                Text(tB.nome, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('${placar.placarB}', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, height: 1)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (vencedorNome != null)
                        Text('🏆 $vencedorNome venceu!',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
                      else
                        const Text('🤝 Empate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Tempo: ${placar.tempoFormatado}  ·  Total de gols: $totalGols',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Artilharia
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('⚽ Artilharia da partida', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      if (artilharia.isEmpty)
                        const Text('Nenhum gol registrado.', style: TextStyle(color: Colors.black54))
                      else
                        ...artilharia.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ev = entry.value.key;
                          final gols = entry.value.value;
                          final medalha = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '  ';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: i == 0 ? Colors.yellow.shade50 : null,
                              border: Border.all(color: i == 0 ? Colors.yellow.shade200 : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(medalha, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  radius: 16,
                                  child: Text(
                                    (ev.jogadorNome ?? '?').substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ev.jogadorNome ?? 'Desconhecido',
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                      if (ev.timeNome != null)
                                        Text(ev.timeNome!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                Text('$gols', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                                const SizedBox(width: 4),
                                Text(gols == 1 ? 'gol' : 'gols', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Linha do tempo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📜 Linha do tempo', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...placar.eventos
                          .where((e) => ['inicio', 'gol', 'gol_contra', 'fim'].contains(e.tipo))
                          .map((ev) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                leading: SizedBox(
                                  width: 50,
                                  child: Text("${ev.minuto}'",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontFamily: 'monospace')),
                                ),
                                title: Text(ev.jogadorNome ?? ev.tipo),
                                subtitle: ev.timeNome != null ? Text(ev.timeNome!) : null,
                                trailing: Text(ev.icone, style: const TextStyle(fontSize: 22)),
                              )),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
