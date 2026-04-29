class AppConfig {
  // Em emulador Android, 10.0.2.2 = localhost do host.
  // Para web/iOS, ajuste para http://127.0.0.1/AlfaFut/public/api/v1
  static const baseUrl = String.fromEnvironment(
    'ALFAFUT_API_URL',
    defaultValue: 'http://10.0.2.2/AlfaFut/public/api/v1',
  );

  static const appName = 'AlfaFut';
}
