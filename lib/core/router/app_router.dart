import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/acessibilidade/presentation/acessibilidade_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/registrar_page.dart';
import '../../features/despesas/presentation/despesa_detalhe_page.dart';
import '../../features/despesas/presentation/despesas_page.dart';
import '../../features/partidas/presentation/partida_detalhe_page.dart';
import '../../features/patotas/presentation/dashboard_page.dart';
import '../../features/patotas/presentation/nova_patota_page.dart';
import '../../features/patotas/presentation/patota_detalhe_page.dart';
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
      final publica = state.matchedLocation == '/login' || state.matchedLocation == '/registrar';
      if (!autenticado && !publica) return '/login';
      if (autenticado && publica) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/registrar', builder: (_, __) => const RegistrarPage()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/acessibilidade', builder: (_, __) => const AcessibilidadePage()),
      GoRoute(path: '/patotas/nova', builder: (_, __) => const NovaPatotaPage()),
      GoRoute(
        path: '/patotas/:id',
        builder: (_, st) => PatotaDetalhePage(patotaId: int.parse(st.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/partidas/:id',
        builder: (_, st) => PartidaDetalhePage(partidaId: int.parse(st.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/patotas/:id/despesas',
        builder: (_, st) => DespesasPage(patotaId: int.parse(st.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/despesas/:id',
        builder: (_, st) => DespesaDetalhePage(despesaId: int.parse(st.pathParameters['id']!)),
      ),
    ],
  );
});
