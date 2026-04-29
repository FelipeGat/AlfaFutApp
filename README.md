# AlfaFutApp

App Flutter do **AlfaFut** - solucao colaborativa para gestao de patota de futebol com suporte de acessibilidade.

Consome a API REST do backend Laravel em `../AlfaFut`.

## Stack

- Flutter 3.41 + Dart 3.11
- **Riverpod** para estado global
- **go_router** para roteamento declarativo
- **Dio** para HTTP com interceptor de Bearer token
- **flutter_secure_storage** para guardar token de sessao
- **Material Design 3** com tema de alto contraste opcional

## Como rodar

```bash
flutter pub get

# emulador Android (10.0.2.2 = localhost do host)
flutter run

# para apontar para outro host
flutter run --dart-define=ALFAFUT_API_URL=http://192.168.0.10/AlfaFut/public/api/v1
```

## Estrutura

```
lib/
  main.dart                                  # entry point
  core/
    config.dart                              # baseUrl da API
    providers.dart                           # providers Riverpod
    theme/app_theme.dart                     # Material 3 + alto contraste
    network/api_client.dart                  # Dio com Bearer token
    storage/token_storage.dart               # secure storage
    router/app_router.dart                   # go_router + redirect auth
  features/
    auth/
      data/usuario.dart                      # entidade
      data/auth_repository.dart              # login, registrar, eu, sair
      presentation/login_page.dart
      presentation/registrar_page.dart
    patotas/
      data/patota.dart
      data/patota_repository.dart
      presentation/dashboard_page.dart       # home apos login
      presentation/patota_detalhe_page.dart  # lista partidas
      presentation/nova_patota_page.dart
    partidas/
      data/partida.dart
      data/partida_repository.dart
      presentation/partida_detalhe_page.dart # confirmar / recusar
    acessibilidade/
      presentation/acessibilidade_page.dart  # WCAG 2.1
```

## Acessibilidade (WCAG 2.1)

- Tamanho de fonte ajustavel (pequena/media/grande/extra grande).
- Tema de alto contraste (preto/amarelo).
- `MediaQuery.disableAnimations` quando o usuario marca "reduzir movimento".
- `Semantics` em mensagens de erro com `liveRegion: true`.
- Tooltips em todos os IconButtons.
- Botoes com `min size 48dp` (Material 3 padrao).

## Login do seed

- E-mail: `admin@alfafut.test`
- Senha: `senha1234`
