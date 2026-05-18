import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../shared/ui/feedback.dart';

class NovaDespesaPage extends ConsumerStatefulWidget {
  const NovaDespesaPage({super.key, required this.patotaId});
  final int patotaId;

  @override
  ConsumerState<NovaDespesaPage> createState() => _NovaDespesaPageState();
}

class _NovaDespesaPageState extends ConsumerState<NovaDespesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  String _categoria = 'locacao';
  DateTime _data = DateTime.now();
  bool _ratear = true;
  bool _enviando = false;

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova despesa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _descricaoCtrl,
              decoration: const InputDecoration(
                labelText: 'Descricao *',
                hintText: 'Ex: Aluguel do campo - sabado',
              ),
              validator: (v) => v != null && v.length >= 3 ? null : 'Informe a descricao',
              maxLength: 160,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoria *'),
              items: const [
                DropdownMenuItem(value: 'locacao', child: Text('Locacao do campo')),
                DropdownMenuItem(value: 'arbitragem', child: Text('Arbitragem')),
                DropdownMenuItem(value: 'material', child: Text('Material (bolas, coletes)')),
                DropdownMenuItem(value: 'alimentacao', child: Text('Alimentacao')),
                DropdownMenuItem(value: 'outro', child: Text('Outro')),
              ],
              onChanged: (v) => setState(() => _categoria = v ?? 'outro'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valorCtrl,
              decoration: const InputDecoration(
                labelText: 'Valor total (R\$) *',
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                return (n != null && n > 0) ? null : 'Informe um valor maior que 0';
              },
            ),
            const SizedBox(height: 12),
            // Data
            InkWell(
              onTap: _selecionarData,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data da despesa *',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_data)),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Ratear automaticamente'),
              subtitle: const Text('Divide o valor entre os confirmados da partida (precisa vincular partida).'),
              value: _ratear,
              onChanged: (v) => setState(() => _ratear = v),
            ),

            const SizedBox(height: 24),
            FilledButton(
              onPressed: _enviando ? null : _salvar,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _enviando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Cadastrar despesa', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ref.read(despesaRepositoryProvider).criar(
            widget.patotaId,
            descricao: _descricaoCtrl.text.trim(),
            categoria: _categoria,
            valorTotal: double.parse(_valorCtrl.text.replaceAll(',', '.')),
            dataDespesa: _data,
            rateada: _ratear,
          );
      ref.invalidate(despesasPorPatotaProvider(widget.patotaId));
      if (mounted) {
        AppFeedback.sucesso(context, 'Despesa cadastrada!');
        context.pop();
      }
    } catch (e) {
      if (mounted) AppFeedback.erro(context, e);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}
