import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../data/despesa.dart';

class DespesasPage extends ConsumerWidget {
  const DespesasPage({super.key, required this.patotaId});
  final int patotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final despesasAsync = ref.watch(despesasPorPatotaProvider(patotaId));
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(despesasPorPatotaProvider(patotaId)),
          ),
        ],
      ),
      body: despesasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (despesasRaw) {
          final despesas = despesasRaw as List<Despesa>;
          if (despesas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('Nenhuma despesa', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    const Text('As despesas cadastradas pelo administrador apareceram aqui.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: despesas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final d = despesas[i];
              final temAberto = d.saldoAberto > 0;
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    child: Icon(_iconePorCategoria(d.categoria)),
                  ),
                  title: Text(d.descricao),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${_rotuloCategoria(d.categoria)} • ${DateFormat('dd/MM/yyyy').format(d.dataDespesa)}',
                      ),
                      if (d.rateada)
                        Text(
                          'Pago: ${formatador.format(d.totalPago)} de ${formatador.format(d.valorTotal)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatador.format(d.valorTotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: temAberto ? const Color(0xFFFFF59D) : const Color(0xFFB9F6CA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          temAberto ? 'aberto' : 'quitada',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/despesas/${d.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconePorCategoria(String categoria) {
    return switch (categoria) {
      'locacao' => Icons.location_on,
      'arbitragem' => Icons.sports,
      'material' => Icons.sports_soccer,
      'alimentacao' => Icons.restaurant,
      _ => Icons.attach_money,
    };
  }

  String _rotuloCategoria(String categoria) {
    return switch (categoria) {
      'locacao' => 'Locacao',
      'arbitragem' => 'Arbitragem',
      'material' => 'Material',
      'alimentacao' => 'Alimentacao',
      _ => 'Outro',
    };
  }
}
