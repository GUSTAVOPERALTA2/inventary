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
        child: Column(
          children: [
            const Spacer(flex: 3),
            Image.asset('assets/images/bajapro_logo.png', width: 180),
            const SizedBox(height: 24),
            const Text(
              'BAJAPRO',
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(flex: 4),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Created by Gustavo Peralta',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
