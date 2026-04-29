import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';

class RegistrarPage extends ConsumerStatefulWidget {
  const RegistrarPage({super.key});

  @override
  ConsumerState<RegistrarPage> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends ConsumerState<RegistrarPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _apelidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (a, b) {
      if (b.autenticado) context.go('/dashboard');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome completo *'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v != null && v.length >= 3 ? null : 'Informe seu nome',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apelidoCtrl,
                  decoration: const InputDecoration(labelText: 'Apelido (opcional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'E-mail *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'E-mail invalido',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefoneCtrl,
                  decoration: const InputDecoration(labelText: 'Telefone (opcional)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _senhaCtrl,
                  decoration: const InputDecoration(labelText: 'Senha *'),
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 8 ? null : 'Use 8+ caracteres',
                ),
                if (estado.erro != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(estado.erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: estado.carregando ? null : _enviar,
                    child: estado.carregando
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Criar conta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).registrar(
          nome: _nomeCtrl.text.trim(),
          apelido: _apelidoCtrl.text.trim().isEmpty ? null : _apelidoCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim().isEmpty ? null : _telefoneCtrl.text.trim(),
          senha: _senhaCtrl.text,
        );
  }
}
