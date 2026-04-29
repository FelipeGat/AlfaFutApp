import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';

final despesaDetalheProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, id) async {
  return ref.read(despesaRepositoryProvider).obter(id);
});

class DespesaDetalhePage extends ConsumerWidget {
  const DespesaDetalhePage({super.key, required this.despesaId});
  final int despesaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalheAsync = ref.watch(despesaDetalheProvider(despesaId));
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final usuarioAtualId = ref.watch(authControllerProvider).usuario?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Despesa')),
      body: detalheAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (dados) {
          final d = dados['despesa']['data'] as Map<String, dynamic>? ?? dados['despesa'] as Map<String, dynamic>;
          final pagamentos = (dados['pagamentos'] as List).cast<Map<String, dynamic>>();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(despesaDetalheProvider(despesaId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['descricao'] as String,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: ${formatador.format((d['valor_total'] as num).toDouble())}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _resumoChip(
                              'Pago',
                              formatador.format((d['total_pago'] as num).toDouble()),
                              Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _resumoChip(
                              'Aberto',
                              formatador.format((d['saldo_aberto'] as num).toDouble()),
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Pagamentos (${pagamentos.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                if (pagamentos.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Esta despesa nao foi rateada.'),
                    ),
                  )
                else
                  ...pagamentos.map((p) => _itemPagamento(context, ref, p, usuarioAtualId, formatador)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _resumoChip(String rotulo, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: const TextStyle(fontSize: 11)),
          Text(valor, style: TextStyle(fontWeight: FontWeight.bold, color: cor)),
        ],
      ),
    );
  }

  Widget _itemPagamento(BuildContext context, WidgetRef ref, Map<String, dynamic> p,
      int? usuarioAtualId, NumberFormat formatador) {
    final podePagar = p['id'] != null && (p['status'] as String) != 'pago';
    final ehMeu = p['user_id'] == usuarioAtualId;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text((p['usuario'] as String).substring(0, 1).toUpperCase()),
        ),
        title: Text(p['usuario'] as String),
        subtitle: Text(
          'Devido: ${formatador.format((p['valor_devido'] as num).toDouble())} '
          '• Pago: ${formatador.format((p['valor_pago'] as num).toDouble())}',
        ),
        trailing: _statusChip(p['status'] as String),
        onTap: ehMeu && podePagar ? () => _abrirDialogoPagamento(context, ref, p) : null,
      ),
    );
  }

  Widget _statusChip(String status) {
    final (cor, texto) = switch (status) {
      'pago' => (Colors.green, 'Pago'),
      'parcial' => (Colors.orange, 'Parcial'),
      _ => (Colors.grey, 'Pendente'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto, style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _abrirDialogoPagamento(
      BuildContext context, WidgetRef ref, Map<String, dynamic> pagamento) async {
    final valorCtrl = TextEditingController(
      text: ((pagamento['valor_devido'] as num) - (pagamento['valor_pago'] as num)).toString(),
    );
    String forma = 'pix';

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Registrar pagamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valorCtrl,
                decoration: const InputDecoration(labelText: 'Valor pago (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: forma,
                decoration: const InputDecoration(labelText: 'Forma'),
                items: const [
                  DropdownMenuItem(value: 'pix', child: Text('PIX')),
                  DropdownMenuItem(value: 'dinheiro', child: Text('Dinheiro')),
                  DropdownMenuItem(value: 'transferencia', child: Text('Transferencia')),
                  DropdownMenuItem(value: 'cartao', child: Text('Cartao')),
                ],
                onChanged: (v) => setState(() => forma = v ?? 'pix'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirmar')),
          ],
        ),
      ),
    );

    if (resultado == true) {
      try {
        await ref.read(despesaRepositoryProvider).quitarPagamento(
              pagamento['id'] as int,
              valorPago: double.parse(valorCtrl.text.replaceAll(',', '.')),
              formaPagamento: forma,
            );
        ref.invalidate(despesaDetalheProvider(despesaId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pagamento registrado!')),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao registrar pagamento.')),
          );
        }
      }
    }
  }
}
