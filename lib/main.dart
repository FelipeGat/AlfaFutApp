import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const ProviderScope(child: AlfaFutApp()));
}

class AlfaFutApp extends ConsumerStatefulWidget {
  const AlfaFutApp({super.key});

  @override
  ConsumerState<AlfaFutApp> createState() => _AlfaFutAppState();
}

class _AlfaFutAppState extends ConsumerState<AlfaFutApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).verificarSessao();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authControllerProvider).usuario;
    final router = ref.watch(appRouterProvider);

    final escala = switch (usuario?.tamanhoFonte) {
      'pequena' => 0.875,
      'grande' => 1.125,
      'extra_grande' => 1.375,
      _ => 1.0,
    };
    final altoContraste = usuario?.altoContraste ?? false;

    return MaterialApp.router(
      title: 'AlfaFut',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(escalaFonte: escala, altoContraste: altoContraste),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      builder: (context, child) {
        if (usuario?.reduzirMovimento == true) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child ?? const SizedBox(),
          );
        }
        return child ?? const SizedBox();
      },
    );
  }
}
