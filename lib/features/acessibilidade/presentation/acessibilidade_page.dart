import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

class AcessibilidadePage extends ConsumerStatefulWidget {
  const AcessibilidadePage({super.key});

  @override
  ConsumerState<AcessibilidadePage> createState() => _AcessibilidadePageState();
}

class _AcessibilidadePageState extends ConsumerState<AcessibilidadePage> {
  late bool _altoContraste;
  late String _tamanhoFonte;
  late bool _reduzirMovimento;
  late bool _leitorTela;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authControllerProvider).usuario;
    _altoContraste = u?.altoContraste ?? false;
    _tamanhoFonte = u?.tamanhoFonte ?? 'media';
    _reduzirMovimento = u?.reduzirMovimento ?? false;
    _leitorTela = (u?.preferenciasAcessibilidade?['leitor_tela_otimizado'] as bool?) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acessibilidade')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _Cabecalho('Visualizacao'),
          SwitchListTile(
            title: const Text('Alto contraste'),
            subtitle: const Text('Tema preto e amarelo (WCAG 1.4.6)'),
            value: _altoContraste,
            onChanged: (v) => setState(() => _altoContraste = v),
          ),
          ListTile(
            title: const Text('Tamanho da fonte'),
            subtitle: Wrap(
              spacing: 8,
              children: [
                _opcaoFonte('pequena', 'Pequena'),
                _opcaoFonte('media', 'Media'),
                _opcaoFonte('grande', 'Grande'),
                _opcaoFonte('extra_grande', 'Extra grande'),
              ],
            ),
          ),
          const _Cabecalho('Movimento e leitor de tela'),
          SwitchListTile(
            title: const Text('Reduzir animacoes'),
            subtitle: const Text('Diminui transicoes (WCAG 2.3.3)'),
            value: _reduzirMovimento,
            onChanged: (v) => setState(() => _reduzirMovimento = v),
          ),
          SwitchListTile(
            title: const Text('Otimizar para leitor de tela'),
            subtitle: const Text('Descricoes detalhadas em todos os elementos.'),
            value: _leitorTela,
            onChanged: (v) => setState(() => _leitorTela = v),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Salvar preferencias'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcaoFonte(String valor, String rotulo) {
    final selecionado = _tamanhoFonte == valor;
    return ChoiceChip(
      label: Text(rotulo),
      selected: selecionado,
      onSelected: (_) => setState(() => _tamanhoFonte = valor),
    );
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.dio.patch('/perfil/acessibilidade', data: {
        'alto_contraste': _altoContraste,
        'tamanho_fonte': _tamanhoFonte,
        'reduzir_movimento': _reduzirMovimento,
        'leitor_tela_otimizado': _leitorTela,
      });
      await ref.read(authControllerProvider.notifier).verificarSessao();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferencias salvas.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar.')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
