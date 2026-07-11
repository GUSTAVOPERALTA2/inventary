import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/database.dart';
import '../../core/utils/cantidad_parser.dart';
import '../../data/repositories/articulos_repository.dart';
import 'articulo_form_screen.dart';

class ArticulosListScreen extends StatelessWidget {
  const ArticulosListScreen({
    super.key,
    required this.loteId,
    required this.nombreLote,
  });

  final int loteId;
  final String nombreLote;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ArticulosRepository>();

    return Scaffold(
      appBar: AppBar(title: Text(nombreLote)),
      body: StreamBuilder<List<Articulo>>(
        stream: repo.watchArticulosByLote(loteId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final articulos = snapshot.data!;
          if (articulos.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no hay artículos en este lote. Agrega el primero con el botón +.',
              ),
            );
          }
          return ListView.builder(
            itemCount: articulos.length,
            itemBuilder: (context, index) {
              final articulo = articulos[index];
              final fotoPath = articulo.fotoPath;
              return ListTile(
                leading: fotoPath == null
                    ? const CircleAvatar(child: Icon(Icons.inventory_2_outlined))
                    : CircleAvatar(backgroundImage: FileImage(File(fotoPath))),
                title: Text(articulo.noSerie),
                subtitle: Text(
                  '${articulo.descripcion} · cant. ${formatCantidad(articulo.cantidad)}',
                ),
                onTap: () => _abrirFormulario(context, articulo: articulo),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  onPressed: () => _confirmarEliminar(context, repo, articulo),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        tooltip: 'Nuevo artículo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _abrirFormulario(BuildContext context, {Articulo? articulo}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticuloFormScreen(loteId: loteId, articulo: articulo),
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    ArticulosRepository repo,
    Articulo articulo,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: Text('¿Eliminar "${articulo.noSerie}"? Esta acción no se puede deshacer.'),
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
      await repo.eliminarArticulo(articulo.id);
    }
  }
}
