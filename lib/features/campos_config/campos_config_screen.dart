import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/database.dart';
import '../../data/models/campo_tipo.dart';
import '../../data/repositories/campos_config_repository.dart';
import 'campo_definicion_form_screen.dart';

class CamposConfigScreen extends StatelessWidget {
  const CamposConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CamposConfigRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Campos configurables')),
      body: StreamBuilder<List<CustomFieldDefinition>>(
        stream: repo.watchAllDefinitions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final definiciones = snapshot.data!;
          if (definiciones.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no hay campos configurables. Agrega el primero con el botón +.',
              ),
            );
          }
          return ListView.builder(
            itemCount: definiciones.length,
            itemBuilder: (context, index) {
              final definicion = definiciones[index];
              final opciones = definicion.opciones;
              final subtitulo = definicion.tipo == CampoTipo.lista &&
                      opciones != null &&
                      opciones.isNotEmpty
                  ? '${definicion.tipo.label} · ${opciones.join(', ')}'
                  : definicion.tipo.label;
              return ListTile(
                title: Text(
                  definicion.nombre,
                  style: definicion.activo
                      ? null
                      : const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                ),
                subtitle: Text(
                  definicion.activo ? subtitulo : '$subtitulo · eliminado',
                ),
                trailing: definicion.activo
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Eliminar',
                        onPressed: () =>
                            _confirmarEliminar(context, repo, definicion),
                      )
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CampoDefinicionFormScreen()),
        ),
        tooltip: 'Nuevo campo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    CamposConfigRepository repo,
    CustomFieldDefinition definicion,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar campo'),
        content: Text(
          '¿Eliminar "${definicion.nombre}"? Ya no aparecerá en nuevas '
          'capturas, pero los artículos que ya lo tienen conservan su valor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado ?? false) {
      await repo.eliminarDefinicion(definicion.id);
    }
  }
}
