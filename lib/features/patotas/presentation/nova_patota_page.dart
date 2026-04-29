import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/clubes.dart';
import '../../../core/providers.dart';
import '../../../shared/brasao_svg.dart';

class NovaPatotaPage extends ConsumerStatefulWidget {
  const NovaPatotaPage({super.key});

  @override
  ConsumerState<NovaPatotaPage> createState() => _NovaPatotaPageState();
}

class _NovaPatotaPageState extends ConsumerState<NovaPatotaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  int _jogadoresPorTime = 5;
  int _quantidadeTimes = 2;
  bool _publica = false;
  bool _enviando = false;
  String? _brasaoEscolhido;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova turma')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome da turma *'),
              validator: (v) => v != null && v.length >= 3 ? null : 'Informe o nome',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descricao'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cidadeCtrl,
              decoration: const InputDecoration(labelText: 'Cidade'),
            ),
            const SizedBox(height: 16),

            // Picker de brasao
            const Text('Escolha o brasao da turma',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('20 clubes ficticios disponiveis. Toque para selecionar.',
                style: TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: kClubes.length,
              itemBuilder: (_, i) {
                final clube = kClubes[i];
                final selecionado = _brasaoEscolhido == clube.brasao;
                return GestureDetector(
                  onTap: () => setState(() => _brasaoEscolhido = clube.brasao),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selecionado ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                        width: selecionado ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: selecionado ? Theme.of(context).colorScheme.primaryContainer : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: BrasaoSvg(path: clube.brasao, size: 56, semanticLabel: clube.nome)),
                        Text(
                          clube.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _jogadoresPorTime,
                  decoration: const InputDecoration(labelText: 'Jogadores por time'),
                  items: const [
                    DropdownMenuItem(value: 4, child: Text('4 (futsal)')),
                    DropdownMenuItem(value: 5, child: Text('5 (society)')),
                    DropdownMenuItem(value: 7, child: Text('7')),
                    DropdownMenuItem(value: 11, child: Text('11 (campo)')),
                  ],
                  onChanged: (v) => setState(() => _jogadoresPorTime = v ?? 5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _quantidadeTimes,
                  decoration: const InputDecoration(labelText: 'Times'),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                    DropdownMenuItem(value: 4, child: Text('4')),
                  ],
                  onChanged: (v) => setState(() => _quantidadeTimes = v ?? 2),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Turma publica'),
              subtitle: const Text('Aparece em buscas - novos membros podem pedir para entrar.'),
              value: _publica,
              onChanged: (v) => setState(() => _publica = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Criar turma'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ref.read(patotaRepositoryProvider).criar(
            nome: _nomeCtrl.text.trim(),
            descricao: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            cidade: _cidadeCtrl.text.trim().isEmpty ? null : _cidadeCtrl.text.trim(),
            jogadoresPorTime: _jogadoresPorTime,
            quantidadeTimes: _quantidadeTimes,
            publica: _publica,
            brasao: _brasaoEscolhido,
          );
      ref.invalidate(patotasProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nao foi possivel criar a turma.')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}
