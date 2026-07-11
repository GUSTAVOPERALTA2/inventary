import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Pantalla de escaneo de QR/código de barras. Al detectar un código,
/// devuelve su valor con `Navigator.pop`. La captura manual del no. de
/// serie sigue disponible siempre: esta pantalla es solo un atajo, no
/// reemplaza al campo de texto del formulario.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _yaDetectado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_yaDetectado) return;
          final codigos = capture.barcodes;
          if (codigos.isEmpty) return;
          final valor = codigos.first.rawValue;
          if (valor == null || valor.isEmpty) return;
          _yaDetectado = true;
          Navigator.pop(context, valor);
        },
      ),
    );
  }
}
