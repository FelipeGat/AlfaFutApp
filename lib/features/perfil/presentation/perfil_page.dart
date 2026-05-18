import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../shared/ui/feedback.dart';

class PerfilPage extends ConsumerStatefulWidget {
  const PerfilPage({super.key});

  @override
  ConsumerState<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends ConsumerState<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeCtrl;
  late TextEditingController _apelidoCtrl;
  late TextEditingController _telefoneCtrl;
  String? _posicao;
  String? _nivel;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authControllerProvider).usuario;
    _nomeCtrl = TextEditingController(text: u?.nome ?? '');
    _apelidoCtrl = TextEditingController(text: u?.apelido ?? '');
    _telefoneCtrl = TextEditingController(text: u?.telefone ?? '');
    _posicao = u?.posicaoPreferida;
    _nivel = u?.nivelHabilidade;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _apelidoCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authControllerProvider).usuario;
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final ok = await AppFeedback.confirmar(
                context,
                titulo: 'Sair da conta?',
                mensagem: 'Voce precisara fazer login novamente.',
                textoConfirmar: 'Sair',
              );
              if (ok) {
                await ref.read(authControllerProvider.notifier).sair();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: Text(
                  usuario.nomeExibicao.isNotEmpty
                      ? usuario.nomeExibicao.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                usuario.email,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),

            // Dados pessoais
            const Text('Dados pessoais', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome completo *'),
              validator: (v) => v != null && v.length >= 3 ? null : 'Informe seu nome',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apelidoCtrl,
              decoration: const InputDecoration(
                labelText: 'Apelido',
                hintText: 'Como voce quer ser chamado',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefoneCtrl,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // Posicao e nivel
            const Text('Preferencias de jogo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _posicao,
              decoration: const InputDecoration(labelText: 'Posicao preferida'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Sem preferencia')),
                DropdownMenuItem(value: 'goleiro', child: Text('Goleiro')),
                DropdownMenuItem(value: 'zagueiro', child: Text('Zagueiro')),
                DropdownMenuItem(value: 'lateral', child: Text('Lateral')),
                DropdownMenuItem(value: 'meia', child: Text('Meia')),
                DropdownMenuItem(value: 'atacante', child: Text('Atacante')),
              ],
              onChanged: (v) => setState(() => _posicao = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _nivel,
              decoration: const InputDecoration(labelText: 'Nivel de habilidade'),
              items: const [
                DropdownMenuItem(value: 'iniciante', child: Text('Iniciante')),
                DropdownMenuItem(value: 'intermediario', child: Text('Intermediario')),
                DropdownMenuItem(value: 'avancado', child: Text('Avancado')),
              ],
              onChanged: (v) => setState(() => _nivel = v),
            ),

            const SizedBox(height: 32),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _salvando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Salvar alteracoes', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/acessibilidade'),
              icon: const Icon(Icons.accessibility_new),
              label: const Text('Configuracoes de acessibilidade'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      await ref.read(perfilRepositoryProvider).atualizarPerfil(
            nome: _nomeCtrl.text.trim(),
            apelido: _apelidoCtrl.text.trim().isEmpty ? '' : _apelidoCtrl.text.trim(),
            telefone: _telefoneCtrl.text.trim().isEmpty ? '' : _telefoneCtrl.text.trim(),
            posicaoPreferida: _posicao,
            nivelHabilidade: _nivel,
          );
      await ref.read(authControllerProvider.notifier).verificarSessao();
      if (mounted) AppFeedback.sucesso(context, 'Perfil atualizado!');
    } catch (e) {
      if (mounted) AppFeedback.erro(context, e);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}
