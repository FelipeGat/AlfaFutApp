import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../data/partida.dart';

final partidaProvider = FutureProvider.autoDispose.family<Partida, int>((ref, id) async {
  return ref.read(partidaRepositoryProvider).obter(id);
});

class PartidaDetalhePage extends ConsumerWidget {
  const PartidaDetalhePage({super.key, required this.partidaId});
  final int partidaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partidaAsync = ref.watch(partidaProvider(partidaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Partida')),
      body: partidaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (p) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(partidaProvider(partidaId)),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(p.titulo, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                DateFormat("EEEE, d 'de' MMMM 'as' HH:mm", 'pt_BR').format(p.dataHora.toLocal()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              if (p.descricao != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(p.descricao!),
                  ),
                ),
              const SizedBox(height: 12),
              _info('Local', p.localNome ?? 'A definir', icone: Icons.place),
              if (p.localEndereco != null) _info('Endereco', p.localEndereco!, icone: Icons.map),
              if (p.localAcessivel == true)
                _info('Acessibilidade', 'Local acessivel para cadeirantes',
                    icone: Icons.accessible_forward),
              _info('Duracao', '${p.duracaoMinutos} min', icone: Icons.timer),
              _info(
                'Vagas',
                '${p.vagasDisponiveis}/${p.vagasTotal}',
                icone: Icons.group,
              ),
              _info(
                'Valor por jogador',
                'R\$ ${p.valorIndividual.toStringAsFixed(2)}',
                icone: Icons.attach_money,
              ),
              const SizedBox(height: 24),
              if (p.euConfirmei)
                Banner(
                  message: 'Confirmado!',
                  location: BannerLocation.topStart,
                  child: _statusBox(context, 'Voce esta confirmado nesta partida.', Colors.green),
                )
              else if (p.euNaListaEspera)
                _statusBox(context, 'Voce esta na lista de espera.', Colors.orange),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  await ref.read(partidaRepositoryProvider).confirmar(p.id);
                  ref.invalidate(partidaProvider(partidaId));
                },
                icon: const Icon(Icons.check),
                label: Text(p.euConfirmei ? 'Manter confirmacao' : 'Confirmar presenca'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(partidaRepositoryProvider).recusar(p.id);
                  ref.invalidate(partidaProvider(partidaId));
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
      child: Row(
        children: [
          Icon(Icons.info_outline, color: cor),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
