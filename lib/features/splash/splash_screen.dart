import 'dart:async';

import 'package:flutter/material.dart';

import '../lotes/lotes_list_screen.dart';

/// Color de marca de BAJAPRO (RGB 121, 38, 27 / HEX #79261B).
const Color colorMarcaBajapro = Color(0xFF79261B);

/// Pantalla de inicio: logo, nombre de la app y créditos sobre el color de
/// marca. Tras [duracion] navega automáticamente al listado de lotes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.duracion = const Duration(seconds: 2)});

  final Duration duracion;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer(widget.duracion, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LotesListScreen()),
      );
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorMarcaBajapro,
      body: SafeArea(
        child: Stack(
          children: [
            // Center (no Column+Spacer) para que el logo y el texto queden
            // exactamente en el centro geométrico de la pantalla, sin
            // depender de proporciones de flex que podían dejarlo descuadrado.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/bajapro_logo.png', width: 180),
                  const SizedBox(height: 24),
                  const Text(
                    'BAJAPRO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Viceroy Los Cabos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Text(
                'Created by Gustavo Peralta',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
