import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/database.dart';
import '../../core/session/lote_activo_controller.dart';
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
          return ListView.builder(
            itemCount: lotes.length,
            itemBuilder: (context, index) {
              final lote = lotes[index];
              final seleccionado = loteActivo.value == lote.id;
              return ListTile(
                title: Text(lote.nombre),
                subtitle: Text(_formatFecha(lote.fechaCreacion)),
                trailing: seleccionado
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
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
}
