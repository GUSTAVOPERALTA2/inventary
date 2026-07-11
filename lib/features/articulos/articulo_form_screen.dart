import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/db/database.dart';
import '../../core/utils/cantidad_parser.dart';
import '../../data/repositories/articulos_repository.dart';

/// Formulario de alta/edicion de un articulo dentro de un lote.
/// Si [articulo] viene null es un alta; si no, edita ese articulo.
class ArticuloFormScreen extends StatefulWidget {
  const ArticuloFormScreen({super.key, required this.loteId, this.articulo});

  final int loteId;
  final Articulo? articulo;

  @override
  State<ArticuloFormScreen> createState() => _ArticuloFormScreenState();
}

class _ArticuloFormScreenState extends State<ArticuloFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noSerieController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _cantidadController;
  bool _esEntero = true;

  bool get _esEdicion => widget.articulo != null;

  @override
  void initState() {
    super.initState();
    final articulo = widget.articulo;
    _noSerieController = TextEditingController(text: articulo?.noSerie ?? '');
    _descripcionController =
        TextEditingController(text: articulo?.descripcion ?? '');
    if (articulo != null) {
      _esEntero = articulo.cantidad == articulo.cantidad.roundToDouble();
    }
    _cantidadController = TextEditingController(
      text: articulo == null ? '' : formatCantidad(articulo.cantidad),
    );
  }

  @override
  void dispose() {
    _noSerieController.dispose();
    _descripcionController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar artículo' : 'Nuevo artículo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _noSerieController,
              decoration: const InputDecoration(labelText: 'No. de serie'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'El no. de serie es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'La descripción es obligatoria'
                  : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Entero')),
                ButtonSegment(value: false, label: Text('Decimal')),
              ],
              selected: {_esEntero},
              onSelectionChanged: (seleccion) {
                setState(() => _esEntero = seleccion.first);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.numberWithOptions(
                decimal: !_esEntero,
              ),
              inputFormatters: [
                if (_esEntero)
                  FilteringTextInputFormatter.digitsOnly
                else
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (value) {
                final cantidad =
                    parseCantidad(value ?? '', esEntero: _esEntero);
                return cantidad == null ? 'Cantidad inválida' : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _guardar(context),
              child: Text(_esEdicion ? 'Guardar cambios' : 'Crear artículo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final cantidad =
        parseCantidad(_cantidadController.text, esEntero: _esEntero)!;
    final repo = context.read<ArticulosRepository>();

    if (_esEdicion) {
      final actualizado = widget.articulo!.copyWith(
        noSerie: _noSerieController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        cantidad: cantidad,
      );
      await repo.actualizarArticulo(actualizado);
    } else {
      await repo.crearArticulo(
        loteId: widget.loteId,
        noSerie: _noSerieController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        cantidad: cantidad,
      );
    }

    if (context.mounted) Navigator.pop(context);
  }
}
