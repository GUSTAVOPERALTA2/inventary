import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../core/db/database.dart';
import '../../core/utils/cantidad_parser.dart';
import '../../data/repositories/articulos_repository.dart';
import '../reportes/acta_baja_pdf_generator.dart';
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
      appBar: AppBar(
        title: Text(nombreLote),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Generar reporte PDF',
            onPressed: () => _generarReporte(context, repo),
          ),
        ],
      ),
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
                  '${articulo.descripcion} · '
                  '${formatCantidad(articulo.cantidad)} ${articulo.unidadMedida} · '
                  '\$${formatCantidad(articulo.precioUnitario)} c/u',
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

  Future<void> _generarReporte(
    BuildContext context,
    ArticulosRepository repo,
  ) async {
    final articulos = await repo.watchArticulosByLote(loteId).first;
    if (articulos.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este lote todavía no tiene artículos.'),
          ),
        );
      }
      return;
    }
    if (!context.mounted) return;

    final encabezado = await _pedirDatosActa(context);
    if (encabezado == null) return;

    final pdfBytes = await generarActaBajaPdf(
      articulos: articulos,
      encabezado: encabezado,
    );

    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  Future<EncabezadoActa?> _pedirDatosActa(BuildContext context) async {
    final areaController = TextEditingController();
    final departamentoController = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Datos del acta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: areaController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Área'),
            ),
            TextField(
              controller: departamentoController,
              decoration: const InputDecoration(labelText: 'Departamento'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Generar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return null;

    final ahora = DateTime.now();
    return EncabezadoActa(
      nombreLote: nombreLote,
      area: areaController.text.trim(),
      departamento: departamentoController.text.trim(),
      fecha: ahora,
      hora: '${ahora.hour.toString().padLeft(2, '0')}:'
          '${ahora.minute.toString().padLeft(2, '0')}',
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
