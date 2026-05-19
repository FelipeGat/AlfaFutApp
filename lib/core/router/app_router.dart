import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/acessibilidade/presentation/acessibilidade_page.dart';
import '../../features/admin/presentation/painel_admin_page.dart';
import '../../features/auth/presentation/esqueci_senha_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/registrar_page.dart';
import '../../features/despesas/presentation/despesa_detalhe_page.dart';
import '../../features/despesas/presentation/despesas_page.dart';
import '../../features/despesas/presentation/nova_despesa_page.dart';
import '../../features/mensagens/presentation/mural_page.dart';
import '../../features/partidas/presentation/controle_partida_page.dart';
import '../../features/partidas/presentation/partida_detalhe_page.dart';
import '../../features/partidas/presentation/resultado_page.dart';
import '../../features/patotas/presentation/dashboard_page.dart';
import '../../features/patotas/presentation/nova_patota_page.dart';
import '../../features/patotas/presentation/patota_detalhe_page.dart';
import '../../features/perfil/presentation/perfil_page.dart';
import '../providers.dart';

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (anterior, atual) {
      if (anterior?.autenticado != atual.autenticado) notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notificador = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notificador,
    redirect: (ctx, state) {
      final autenticado = ref.read(authControllerProvider).autenticado;
      final rota = state.matchedLocation;
      final publica = rota == '/login' || rota == '/registrar' || rota == '/esqueci-senha';
      if (!autenticado && !publica) return '/login';
      if (autenticado && publica) return '/dashboard';
      return null;
    },
    routes: [
      // Publicas
      GoRoute(path: '/login', builder: (_, ___) => const LoginPage()),
      GoRoute(path: '/registrar', builder: (_, ___) => const RegistrarPage()),
      GoRoute(path: '/esqueci-senha', builder: (_, ___) => const EsqueciSenhaPage()),

      // Privadas
      GoRoute(path: '/dashboard', builder: (_, ___) => const DashboardPage()),
      GoRoute(path: '/perfil', builder: (_, ___) => const PerfilPage()),
      GoRoute(path: '/acessibilidade', builder: (_, ___) => const AcessibilidadePage()),

      // Admin (acesso global)
      GoRoute(path: '/admin', builder: (_, ___) => const PainelAdminPage()),
      GoRoute(path: '/admin/patotas', builder: (_, ___) => const AdminPatotasPage()),
      GoRoute(path: '/admin/partidas', builder: (_, ___) => const AdminPartidasPage()),
      GoRoute(path: '/admin/usuarios', builder: (_, ___) => const AdminUsuariosPage()),

      // Patotas
      GoRoute(path: '/patotas/nova', builder: (_, ___) => const NovaPatotaPage()),
      GoRoute(
        path: '/patotas/:id',
        builder: (_, st) => PatotaDetalhePage(patotaId: int.parse(st.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/patotas/:id/mural',
        builder: (_, st) => MuralPage(patotaId: int.parse(st.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/patotas/:id/despesas',
        builder: (_, st) => DespesasPage(patotaId: int.parse(st.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/patotas/:id/despesas/nova',
        builder: (_, st) => NovaDespesaPage(patotaId: int.parse(st.pathParameters['id']!)),
      ),

      // Partidas
      GoRoute(
        path: '/partidas/:id',
        builder: (_, st) => PartidaDetalhePage(partidaId: int.parse(st.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/partidas/:id/controle',
        builder: (_, st) => ControlePartidaPage(partidaId: int.parse(st.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/partidas/:id/resultado',
        builder: (_, st) => ResultadoPage(partidaId: int.parse(st.pathParameters['id']!)),
      ),

      // Despesas
      GoRoute(
        path: '/despesas/:id',
        builder: (_, st) => DespesaDetalhePage(despesaId: int.parse(st.pathParameters['id']!)),
      ),
    ],
  );
});
