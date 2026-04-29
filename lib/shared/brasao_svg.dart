import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/config.dart';

/// Renderiza um brasao SVG servido pelo backend Laravel.
/// Aceita path relativo (ex: "images/brasoes/01-aguia-dourada.svg").
class BrasaoSvg extends StatelessWidget {
  const BrasaoSvg({
    super.key,
    required this.path,
    this.size = 64,
    this.semanticLabel,
  });

  final String? path;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return _placeholder();
    }
    final url = AppConfig.assetUrl(path!);
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.network(
        url,
        semanticsLabel: semanticLabel,
        placeholderBuilder: (_) => _placeholder(),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.shield_outlined, color: Colors.grey),
    );
  }
}
