import 'package:flutter/material.dart';

class AppTheme {
  static const Color verdeAlfa = Color(0xFF1B5E20);
  static const Color verdeAlfaContainer = Color(0xFFB9F6CA);
  static const Color laranjaSecundaria = Color(0xFFF57C00);

  static ThemeData claro({double escalaFonte = 1.0, bool altoContraste = false}) {
    final esquema = altoContraste
        ? const ColorScheme(
            brightness: Brightness.light,
            primary: Colors.black,
            onPrimary: Color(0xFFFFFF00),
            secondary: Color(0xFFFFFF00),
            onSecondary: Colors.black,
            error: Color(0xFFD50000),
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          )
        : ColorScheme.fromSeed(
            seedColor: verdeAlfa,
            brightness: Brightness.light,
          ).copyWith(
            primary: verdeAlfa,
            secondary: laranjaSecundaria,
            primaryContainer: verdeAlfaContainer,
          );

    return ThemeData(
      colorScheme: esquema,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto',
      textTheme: _textTheme(escalaFonte, esquema.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(double escala, Color cor) {
    final base = Typography.englishLike2021;
    return TextTheme(
      displayLarge: base.displayLarge?.copyWith(color: cor, fontSize: 48 * escala),
      headlineLarge: base.headlineLarge?.copyWith(color: cor, fontSize: 28 * escala, fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(color: cor, fontSize: 22 * escala, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(color: cor, fontSize: 18 * escala, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(color: cor, fontSize: 16 * escala),
      bodyMedium: base.bodyMedium?.copyWith(color: cor, fontSize: 14 * escala),
      labelLarge: base.labelLarge?.copyWith(color: cor, fontSize: 14 * escala, fontWeight: FontWeight.w600),
    );
  }
}
