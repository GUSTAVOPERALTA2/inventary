import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'version_checker.dart';

/// Diálogo no intrusivo que ofrece descargar la nueva versión. El usuario
/// puede posponerlo ("Más tarde") sin ninguna consecuencia: la app sigue
/// funcionando igual, la actualización no es obligatoria.
Future<void> mostrarDialogoActualizacion(
  BuildContext context,
  InfoVersionRemota info, {
  Future<bool> Function(Uri url, {LaunchMode mode}) abrirUrl = launchUrl,
}) {
  final notas = info.notas;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Actualización disponible'),
      content: Text(
        'Hay una nueva versión de BAJAPRO disponible (${info.versionName}).'
        '${notas != null && notas.isNotEmpty ? '\n\n$notas' : ''}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Más tarde'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await abrirUrl(
              Uri.parse(info.apkUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          child: const Text('Descargar'),
        ),
      ],
    ),
  );
}
