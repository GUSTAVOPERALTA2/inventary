import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/db/database.dart';
import '../../core/utils/cantidad_parser.dart';
import '../../data/models/campo_tipo.dart';
import '../../data/repositories/articulos_repository.dart';
import '../../data/repositories/campos_config_repository.dart';

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

  // Campos configurables (Bloque 4): se cargan una vez al abrir el
  // formulario e inyectan controles adicionales según su tipo.
  bool _cargandoCampos = true;
  List<CustomFieldDefinition> _definiciones = [];
  final Map<int, TextEditingController> _controladoresTexto = {};
  final Map<int, DateTime?> _valoresFecha = {};
  final Map<int, String?> _valoresLista = {};

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
    _cargarDefiniciones();
  }

  Future<void> _cargarDefiniciones() async {
    final definiciones =
        await context.read<CamposConfigRepository>().getActiveDefinitionsOnce();
    final valoresExistentes = widget.articulo?.customValues ?? {};

    for (final definicion in definiciones) {
      final valor = valoresExistentes[definicion.id.toString()];
      switch (definicion.tipo) {
        case CampoTipo.texto:
        case CampoTipo.entero:
        case CampoTipo.decimal:
          _controladoresTexto[definicion.id] =
              TextEditingController(text: valor?.toString() ?? '');
        case CampoTipo.fecha:
          _valoresFecha[definicion.id] =
              valor == null ? null : DateTime.parse(valor as String);
        case CampoTipo.lista:
          _valoresLista[definicion.id] = valor as String?;
      }
    }

    if (mounted) {
      setState(() {
        _definiciones = definiciones;
        _cargandoCampos = false;
      });
    }
  }

  @override
  void dispose() {
    _noSerieController.dispose();
    _descripcionController.dispose();
    _cantidadController.dispose();
    for (final controlador in _controladoresTexto.values) {
      controlador.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar artículo' : 'Nuevo artículo'),
      ),
      body: _cargandoCampos
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _noSerieController,
                    decoration:
                        const InputDecoration(labelText: 'No. de serie'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'El no. de serie es obligatorio'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration:
                        const InputDecoration(labelText: 'Descripción'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
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
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]'),
                        ),
                    ],
                    validator: (value) {
                      final cantidad =
                          parseCantidad(value ?? '', esEntero: _esEntero);
                      return cantidad == null ? 'Cantidad inválida' : null;
                    },
                  ),
                  if (_definiciones.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    for (final definicion in _definiciones) ...[
                      _campoDinamico(definicion),
                      const SizedBox(height: 16),
                    ],
                  ],
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => _guardar(context),
                    child:
                        Text(_esEdicion ? 'Guardar cambios' : 'Crear artículo'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _campoDinamico(CustomFieldDefinition definicion) {
    switch (definicion.tipo) {
      case CampoTipo.texto:
        return TextFormField(
          controller: _controladoresTexto[definicion.id],
          decoration: InputDecoration(labelText: definicion.nombre),
        );
      case CampoTipo.entero:
        return TextFormField(
          controller: _controladoresTexto[definicion.id],
          decoration: InputDecoration(labelText: definicion.nombre),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      case CampoTipo.decimal:
        return TextFormField(
          controller: _controladoresTexto[definicion.id],
          decoration: InputDecoration(labelText: definicion.nombre),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        );
      case CampoTipo.fecha:
        final fecha = _valoresFecha[definicion.id];
        return InkWell(
          onTap: () async {
            final seleccionada = await showDatePicker(
              context: context,
              initialDate: fecha ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (seleccionada != null) {
              setState(() => _valoresFecha[definicion.id] = seleccionada);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(labelText: definicion.nombre),
            child: Text(
              fecha == null
                  ? 'Sin fecha'
                  : '${fecha.day.toString().padLeft(2, '0')}/'
                      '${fecha.month.toString().padLeft(2, '0')}/'
                      '${fecha.year}',
            ),
          ),
        );
      case CampoTipo.lista:
        final opciones = definicion.opciones ?? [];
        return DropdownButtonFormField<String>(
          initialValue: _valoresLista[definicion.id],
          decoration: InputDecoration(labelText: definicion.nombre),
          items: opciones
              .map((opcion) =>
                  DropdownMenuItem(value: opcion, child: Text(opcion)))
              .toList(),
          onChanged: (value) {
            setState(() => _valoresLista[definicion.id] = value);
          },
        );
    }
  }

  Future<void> _guardar(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final cantidad =
        parseCantidad(_cantidadController.text, esEntero: _esEntero)!;
    final repo = context.read<ArticulosRepository>();

    // Se parte de los valores ya guardados (incluidos los de campos que
    // hoy están desactivados) y solo se sobrescriben los de las
    // definiciones activas que aparecieron en este formulario; así una
    // edición no borra el histórico de un campo eliminado.
    final customValues = <String, dynamic>{
      ...?widget.articulo?.customValues,
    };
    for (final definicion in _definiciones) {
      switch (definicion.tipo) {
        case CampoTipo.texto:
          customValues[definicion.id.toString()] =
              _controladoresTexto[definicion.id]!.text.trim();
        case CampoTipo.entero:
          customValues[definicion.id.toString()] =
              int.tryParse(_controladoresTexto[definicion.id]!.text.trim());
        case CampoTipo.decimal:
          customValues[definicion.id.toString()] = double.tryParse(
            _controladoresTexto[definicion.id]!.text.trim().replaceAll(',', '.'),
          );
        case CampoTipo.fecha:
          customValues[definicion.id.toString()] =
              _valoresFecha[definicion.id]?.toIso8601String();
        case CampoTipo.lista:
          customValues[definicion.id.toString()] = _valoresLista[definicion.id];
      }
    }

    if (_esEdicion) {
      final actualizado = widget.articulo!.copyWith(
        noSerie: _noSerieController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        cantidad: cantidad,
        customValues: customValues,
      );
      await repo.actualizarArticulo(actualizado);
    } else {
      await repo.crearArticulo(
        loteId: widget.loteId,
        noSerie: _noSerieController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        cantidad: cantidad,
        customValues: customValues,
      );
    }

    if (context.mounted) Navigator.pop(context);
  }
}
