import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../shared/ui/estados.dart';
import '../../../shared/ui/feedback.dart';
import '../data/mensagem.dart';

class MuralPage extends ConsumerStatefulWidget {
  const MuralPage({super.key, required this.patotaId});
  final int patotaId;

  @override
  ConsumerState<MuralPage> createState() => _MuralPageState();
}

class _MuralPageState extends ConsumerState<MuralPage> {
  final _conteudoCtrl = TextEditingController();
  bool _enviando = false;
  bool _fixar = false;
  String _tipo = 'texto';

  @override
  void dispose() {
    _conteudoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mensagensAsync = ref.watch(mensagensPorPatotaProvider(widget.patotaId));
    final usuarioAtual = ref.watch(authControllerProvider).usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mural da turma'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(mensagensPorPatotaProvider(widget.patotaId)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: mensagensAsync.when(
              loading: () => const CarregandoView(),
              error: (e, _) => ErroView(
                mensagem: e.toString(),
                onRetry: () => ref.invalidate(mensagensPorPatotaProvider(widget.patotaId)),
              ),
              data: (lista) {
                final mensagens = lista as List<Mensagem>;
                if (mensagens.isEmpty) {
                  return const VazioView(
                    icone: Icons.forum_outlined,
                    titulo: 'Nenhuma mensagem ainda',
                    descricao: 'Seja o primeiro a postar no mural!',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(mensagensPorPatotaProvider(widget.patotaId)),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: mensagens.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _MensagemCard(
                      mensagem: mensagens[i],
                      usuarioId: usuarioAtual?.id,
                      onRemover: () => _confirmarRemocao(mensagens[i]),
                    ),
                  ),
                );
              },
            ),
          ),
          // Composer (fixo no rodape)
          Material(
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Mensagem'),
                          selected: _tipo == 'texto',
                          onSelected: (_) => setState(() => _tipo = 'texto'),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('📢 Aviso'),
                          selected: _tipo == 'aviso',
                          onSelected: (_) => setState(() => _tipo = 'aviso'),
                        ),
                        const Spacer(),
                        FilterChip(
                          label: const Text('📌 Fixar'),
                          selected: _fixar,
                          onSelected: (v) => setState(() => _fixar = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _conteudoCtrl,
                            maxLines: 4,
                            minLines: 1,
                            decoration: const InputDecoration(
                              hintText: 'Escreva uma mensagem...',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _enviando ? null : _publicar,
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(14),
                          ),
                          child: _enviando
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publicar() async {
    if (_conteudoCtrl.text.trim().isEmpty) return;
    setState(() => _enviando = true);
    try {
      await ref.read(mensagemRepositoryProvider).publicar(
            widget.patotaId,
            conteudo: _conteudoCtrl.text.trim(),
            tipo: _tipo,
            fixada: _fixar,
          );
      _conteudoCtrl.clear();
      setState(() => _fixar = false);
      ref.invalidate(mensagensPorPatotaProvider(widget.patotaId));
      if (mounted) AppFeedback.sucesso(context, 'Mensagem publicada!');
    } catch (e) {
      if (mounted) AppFeedback.erro(context, e);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _confirmarRemocao(Mensagem m) async {
    final ok = await AppFeedback.confirmar(
      context,
      titulo: 'Remover mensagem?',
      mensagem: 'Esta acao nao pode ser desfeita.',
      textoConfirmar: 'Remover',
      destrutivo: true,
    );
    if (!ok) return;
    try {
      await ref.read(mensagemRepositoryProvider).remover(m.id);
      ref.invalidate(mensagensPorPatotaProvider(widget.patotaId));
      if (mounted) AppFeedback.sucesso(context, 'Mensagem removida.');
    } catch (e) {
      if (mounted) AppFeedback.erro(context, e);
    }
  }
}

class _MensagemCard extends StatelessWidget {
  const _MensagemCard({required this.mensagem, this.usuarioId, this.onRemover});
  final Mensagem mensagem;
  final int? usuarioId;
  final VoidCallback? onRemover;

  @override
  Widget build(BuildContext context) {
    final inicial = mensagem.autorExibicao.isNotEmpty
        ? mensagem.autorExibicao.substring(0, 1).toUpperCase()
        : '?';
    final corFundo = mensagem.fixada
        ? Colors.yellow.shade50
        : (mensagem.tipo == 'aviso' ? Colors.blue.shade50 : null);

    return Card(
      color: corFundo,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text(inicial, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mensagem.autorExibicao, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        _tempo(mensagem.criadaEm),
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (mensagem.fixada)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Text('📌', style: TextStyle(fontSize: 16)),
                  ),
                if (mensagem.tipo == 'aviso')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(4)),
                    child: const Text('AVISO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                if (onRemover != null)
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Remover mensagem'),
                              onTap: () {
                                Navigator.of(context).pop();
                                onRemover!();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(mensagem.conteudo, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  String _tempo(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final agora = DateTime.now();
    final diff = agora.difference(local);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min atras';
    if (diff.inDays < 1) return '${diff.inHours}h atras';
    if (diff.inDays < 7) return '${diff.inDays}d atras';
    return DateFormat('dd/MM HH:mm').format(local);
  }
}
