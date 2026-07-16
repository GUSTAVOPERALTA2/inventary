import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'apk_downloader.dart';
import 'version_checker.dart';

typedef DescargarApkFn = Future<String> Function(
  String url,
  void Function(double? progreso) onProgreso,
);

typedef InstalarApkFn = Future<OpenResult> Function(String rutaArchivo);

enum _EstadoActualizacion { ofreciendo, descargando, instalando, error }

/// Diálogo no intrusivo que ofrece descargar e instalar la nueva versión
/// sin salir de la app (ni depender del navegador). El usuario puede
/// posponerlo ("Más tarde") sin ninguna consecuencia: la app sigue
/// funcionando igual, la actualización no es obligatoria. Android siempre
/// exige la confirmación final de instalar; eso no se puede evitar sin un
/// dispositivo administrado por MDM.
Future<void> mostrarDialogoActualizacion(
  BuildContext context,
  InfoVersionRemota info, {
  DescargarApkFn descargarApkFn = descargarApk,
  InstalarApkFn instalarApkFn = instalarApk,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _DialogoActualizacion(
      info: info,
      descargarApkFn: descargarApkFn,
      instalarApkFn: instalarApkFn,
    ),
  );
}

class _DialogoActualizacion extends StatefulWidget {
  const _DialogoActualizacion({
    required this.info,
    required this.descargarApkFn,
    required this.instalarApkFn,
  });

  final InfoVersionRemota info;
  final DescargarApkFn descargarApkFn;
  final InstalarApkFn instalarApkFn;

  @override
  State<_DialogoActualizacion> createState() => _DialogoActualizacionState();
}

class _DialogoActualizacionState extends State<_DialogoActualizacion> {
  _EstadoActualizacion _estado = _EstadoActualizacion.ofreciendo;
  double? _progreso;
  String _mensajeError = '';

  Future<void> _descargarEInstalar() async {
    setState(() {
      _estado = _EstadoActualizacion.descargando;
      _progreso = 0;
    });
    try {
      final ruta = await widget.descargarApkFn(widget.info.apkUrl, (p) {
        if (mounted) setState(() => _progreso = p);
      });
      if (!mounted) return;

      setState(() => _estado = _EstadoActualizacion.instalando);
      final resultado = await widget.instalarApkFn(ruta);
      if (!mounted) return;

      if (resultado.type != ResultType.done) {
        setState(() {
          _estado = _EstadoActualizacion.error;
          _mensajeError = resultado.type == ResultType.permissionDenied
              ? 'Falta habilitar "Instalar apps desconocidas" para BAJAPRO '
                  'en Ajustes. Actívalo y vuelve a intentar.'
              : (resultado.message.isNotEmpty
                  ? resultado.message
                  : 'No se pudo abrir el instalador.');
        });
        return;
      }
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _estado = _EstadoActualizacion.error;
        _mensajeError = 'No se pudo descargar la actualización. '
            'Revisa tu conexión e intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualización disponible'),
      content: _construirContenido(),
      actions: _construirAcciones(),
    );
  }

  Widget _construirContenido() {
    switch (_estado) {
      case _EstadoActualizacion.ofreciendo:
        final notas = widget.info.notas;
        return Text(
          'Hay una nueva versión de BAJAPRO disponible '
          '(${widget.info.versionName}).'
          '${notas != null && notas.isNotEmpty ? '\n\n$notas' : ''}',
        );
      case _EstadoActualizacion.descargando:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Descargando actualización...'),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _progreso),
            if (_progreso != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${(_progreso! * 100).toStringAsFixed(0)}%'),
              ),
          ],
        );
      case _EstadoActualizacion.instalando:
        return const Text('Abriendo el instalador...');
      case _EstadoActualizacion.error:
        return Text(_mensajeError);
    }
  }

  List<Widget> _construirAcciones() {
    switch (_estado) {
      case _EstadoActualizacion.ofreciendo:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde'),
          ),
          FilledButton(
            onPressed: _descargarEInstalar,
            child: const Text('Descargar'),
          ),
        ];
      case _EstadoActualizacion.descargando:
      case _EstadoActualizacion.instalando:
        return const [];
      case _EstadoActualizacion.error:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: _descargarEInstalar,
            child: const Text('Reintentar'),
          ),
        ];
    }
  }
}
