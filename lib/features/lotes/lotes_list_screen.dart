import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/database.dart';
import '../../core/session/lote_activo_controller.dart';
import '../../data/repositories/articulos_repository.dart';
import '../../data/repositories/lotes_repository.dart';
import '../articulos/articulos_list_screen.dart';

class LotesListScreen extends StatelessWidget {
  const LotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<LotesRepository>();
    final loteActivo = context.watch<LoteActivoController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotes'),
      ),
      body: StreamBuilder<List<Lote>>(
        stream: repo.watchLotes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lotes = snapshot.data!;
          if (lotes.isEmpty) {
            return const Center(
              child: Text('Todavía no hay lotes. Crea el primero con el botón +.'),
            );
          }
          return ReorderableListView.builder(
            // El agarre (drag_handle) es la unica zona que arrastra; el
            // resto de la fila sigue respondiendo al tap normal de abrir.
            buildDefaultDragHandles: false,
            itemCount: lotes.length,
            onReorderItem: (oldIndex, newIndex) =>
                _reordenar(repo, lotes, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final lote = lotes[index];
              final seleccionado = loteActivo.value == lote.id;
              return ListTile(
                key: ValueKey(lote.id),
                title: Text(lote.nombre),
                subtitle: Text(_formatFecha(lote.fechaCreacion)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (seleccionado)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_circle, color: Colors.green),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Renombrar',
                      onPressed: () => _editarLote(context, repo, lote),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Eliminar',
                      onPressed: () => _confirmarEliminarLote(context, repo, lote),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.drag_handle),
                      ),
                    ),
                  ],
                ),
                selected: seleccionado,
                onTap: () {
                  loteActivo.seleccionar(lote.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticulosListScreen(
                        loteId: lote.id,
                        nombreLote: lote.nombre,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearLote(context, repo),
        tooltip: 'Nuevo lote',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatFecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';

  Future<void> _reordenar(
    LotesRepository repo,
    List<Lote> lotesActuales,
    int oldIndex,
    int newIndex,
  ) {
    final nuevaLista = List<Lote>.from(lotesActuales);
    final movido = nuevaLista.removeAt(oldIndex);
    nuevaLista.insert(newIndex, movido);
    return repo.reordenarLotes(nuevaLista.map((l) => l.id).toList());
  }

  Future<void> _mostrarDialogoCrearLote(
    BuildContext context,
    LotesRepository repo,
  ) async {
    final controller = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nuevo lote'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del lote'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    if (nombre != null && nombre.isNotEmpty) {
      await repo.crearLote(nombre);
    }
  }

  Future<void> _editarLote(
    BuildContext context,
    LotesRepository repo,
    Lote lote,
  ) async {
    final controller = TextEditingController(text: lote.nombre);
    final nuevoNombre = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renombrar lote'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del lote'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevoNombre != null &&
        nuevoNombre.isNotEmpty &&
        nuevoNombre != lote.nombre) {
      await repo.renombrarLote(lote, nuevoNombre);
    }
  }

  Future<void> _confirmarEliminarLote(
    BuildContext context,
    LotesRepository repo,
    Lote lote,
  ) async {
    final articulosRepo = context.read<ArticulosRepository>();
    final articulos = await articulosRepo.watchArticulosByLote(lote.id).first;

    if (!context.mounted) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar lote'),
        content: Text(
          articulos.isEmpty
              ? '¿Eliminar el lote "${lote.nombre}"? Esta acción no se puede deshacer.'
              : '¿Eliminar el lote "${lote.nombre}"? También se eliminarán '
                  'sus ${articulos.length} artículo(s) y sus fotografías. '
                  'Esta acción no se puede deshacer.',
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
    if (confirmado != true) return;

    for (final articulo in articulos) {
      final fotoPath = articulo.fotoPath;
      if (fotoPath == null) continue;
      final archivo = File(fotoPath);
      if (await archivo.exists()) {
        await archivo.delete();
      }
    }
    await articulosRepo.eliminarArticulosDelLote(lote.id);
    await repo.eliminarLote(lote.id);

    if (!context.mounted) return;
    final loteActivo = context.read<LoteActivoController>();
    if (loteActivo.value == lote.id) loteActivo.limpiar();
  }
}
