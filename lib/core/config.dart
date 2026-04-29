class AppConfig {
  // Em emulador Android, 10.0.2.2 = localhost do host.
  // Para web/iOS, ajuste para http://127.0.0.1/AlfaFut/public/api/v1
  static const baseUrl = String.fromEnvironment(
    'ALFAFUT_API_URL',
    defaultValue: 'http://10.0.2.2/AlfaFut/public/api/v1',
  );

  static const appName = 'AlfaFut';

  /// Retorna URL absoluta de um asset publico do backend (ex: brasao SVG).
  /// Recebe path relativo como "images/brasoes/01-aguia.svg".
  static String assetUrl(String relativePath) {
    final base = baseUrl.replaceFirst(RegExp(r'/api/v\d+/?$'), '');
    final pathLimpo = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return '$base/$pathLimpo';
  }
}
