import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/database.dart';
import '../../core/utils/cantidad_parser.dart';
import '../../data/repositories/articulos_repository.dart';
import '../../data/repositories/campos_config_repository.dart';
import '../reportes/acta_baja_pdf_generator.dart';
import '../reportes/lote_zip_calculos.dart';
import '../reportes/lote_zip_exporter.dart';
import 'articulo_form_screen.dart';

class ArticulosListScreen extends StatelessWidget {
  const ArticulosListScreen({
    super.key,
    required this.loteId,
    required this.nombreLote,
    this.obtenerDirectorioZip,
    this.compartirArchivo,
  });

  final int loteId;
  final String nombreLote;

  /// Punto de inyección para tests: por defecto resuelve al directorio de
  /// documentos real de la app (path_provider), pero en tests se puede
  /// pasar un directorio temporal para no depender de un plugin nativo.
  final Future<Directory> Function()? obtenerDirectorioZip;

  /// Punto de inyección para tests: por defecto abre el selector nativo
  /// de "compartir" (share_plus); en tests se puede sustituir por un
  /// stub que no dependa del plugin nativo.
  final Future<void> Function(String rutaArchivo, String texto)?
      compartirArchivo;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ArticulosRepository>();
    final camposRepo = context.read<CamposConfigRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreLote),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Generar reporte PDF',
            onPressed: () => _generarReporte(context, repo),
          ),
          IconButton(
            icon: const Icon(Icons.folder_zip_outlined),
            tooltip: 'Exportar ZIP (acta + fotos)',
            onPressed: () => _exportarZip(context, repo, camposRepo),
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

  Future<void> _exportarZip(
    BuildContext context,
    ArticulosRepository repo,
    CamposConfigRepository camposRepo,
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
    final definiciones = await camposRepo.watchAllDefinitions().first;
    final zipBytes = construirZipLote(
      articulos: articulos,
      definiciones: definiciones,
      actaPdfBytes: pdfBytes,
    );

    final resolverDirectorio =
        obtenerDirectorioZip ?? getApplicationDocumentsDirectory;
    final directorioBase = await resolverDirectorio();
    final rutaZip = await guardarZipLote(
      zipBytes: zipBytes,
      nombreArchivo: nombreArchivoZipLote(nombreLote, DateTime.now()),
      directorioBase: directorioBase,
    );

    final compartir = compartirArchivo ??
        (rutaArchivo, texto) async {
          await SharePlus.instance.share(
            ShareParams(files: [XFile(rutaArchivo)], text: texto),
          );
        };
    await compartir(rutaZip, 'Acta y respaldo de fotos del lote "$nombreLote"');

    final articulosConFoto =
        articulos.where((a) => a.fotoPath != null).toList();
    if (articulosConFoto.isEmpty) return;
    if (!context.mounted) return;

    final borrar = await _confirmarBorrarFotos(context, articulosConFoto.length);
    if (borrar != true) return;

    for (final articulo in articulosConFoto) {
      final archivoFoto = File(articulo.fotoPath!);
      if (await archivoFoto.exists()) {
        await archivoFoto.delete();
      }
      await repo.actualizarArticulo(
        articulo.copyWith(fotoPath: const Value(null)),
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotos borradas del dispositivo (ya quedaron en el ZIP).'),
        ),
      );
    }
  }

  Future<bool?> _confirmarBorrarFotos(BuildContext context, int cantidad) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Borrar fotos del dispositivo?'),
        content: Text(
          'Ya se incluyeron $cantidad foto(s) en el ZIP compartido. '
          '¿Quieres borrarlas de este dispositivo para liberar espacio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Conservarlas'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Borrar'),
          ),
        ],
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
