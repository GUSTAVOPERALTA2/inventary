import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/db/database.dart';
import '../../core/utils/cantidad_parser.dart';
import '../../core/utils/foto_storage.dart';
import '../../data/models/campo_tipo.dart';
import '../../data/repositories/articulos_repository.dart';
import '../../data/repositories/campos_config_repository.dart';
import '../camara_scanner/scanner_screen.dart';

/// Opciones fijas del menu desplegable de "Unidad de medida". "Otro" no es
/// una unidad en si: al elegirla se habilita un campo de texto para
/// escribir la unidad real.
const _unidadesPreestablecidas = ['Pieza', 'Kg', 'Ml', 'Lote'];
const _opcionOtroUnidad = 'Otro';

/// Formulario de alta/edicion de un articulo dentro de un lote.
/// Si [articulo] viene null es un alta; si no, edita ese articulo.
class ArticuloFormScreen extends StatefulWidget {
  const ArticuloFormScreen({
    super.key,
    required this.loteId,
    this.articulo,
    this.obtenerDirectorioFotos,
  });

  final int loteId;
  final Articulo? articulo;

  /// Punto de inyección para tests: por defecto resuelve al directorio de
  /// documentos real de la app (path_provider), pero en tests se puede pasar
  /// un directorio temporal para no depender de un plugin nativo.
  final Future<Directory> Function()? obtenerDirectorioFotos;

  @override
  State<ArticuloFormScreen> createState() => _ArticuloFormScreenState();
}

class _ArticuloFormScreenState extends State<ArticuloFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noSerieController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _cantidadController;
  late final TextEditingController _unidadMedidaController;
  late final TextEditingController _precioUnitarioController;
  bool _esEntero = true;
  String? _fotoPath;
  // Valor seleccionado en el menu de "Unidad de medida". Si es
  // [_opcionOtroUnidad], la unidad real se toma de
  // _unidadMedidaController en vez de esta variable.
  String? _unidadMedidaSeleccionada;

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
    final unidadExistente = articulo?.unidadMedida ?? '';
    if (unidadExistente.isEmpty) {
      _unidadMedidaSeleccionada = null;
      _unidadMedidaController = TextEditingController();
    } else if (_unidadesPreestablecidas.contains(unidadExistente)) {
      _unidadMedidaSeleccionada = unidadExistente;
      _unidadMedidaController = TextEditingController();
    } else {
      _unidadMedidaSeleccionada = _opcionOtroUnidad;
      _unidadMedidaController = TextEditingController(text: unidadExistente);
    }
    _precioUnitarioController = TextEditingController(
      text: articulo == null || articulo.precioUnitario == 0
          ? ''
          : formatCantidad(articulo.precioUnitario),
    );
    _fotoPath = articulo?.fotoPath;
    _cargarDefiniciones();
  }

  Future<void> _tomarFoto() async {
    final foto = await ImagePicker().pickImage(source: ImageSource.camera);
    if (foto == null) return;

    final resolverDirectorio =
        widget.obtenerDirectorioFotos ?? getApplicationDocumentsDirectory;
    final directorioBase = await resolverDirectorio();
    final rutaFinal = await guardarFotoArticulo(
      origenPath: foto.path,
      directorioBase: directorioBase,
    );

    if (mounted) setState(() => _fotoPath = rutaFinal);
  }

  void _quitarFoto() => setState(() => _fotoPath = null);

  Future<void> _escanear() async {
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (resultado != null && resultado.isNotEmpty) {
      _noSerieController.text = resultado;
    }
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
    _unidadMedidaController.dispose();
    _precioUnitarioController.dispose();
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
                    decoration: InputDecoration(
                      labelText: 'No. de serie',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Escanear código',
                        onPressed: _escanear,
                      ),
                    ),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _unidadMedidaSeleccionada,
                    decoration:
                        const InputDecoration(labelText: 'Unidad de medida'),
                    items: [
                      for (final unidad in _unidadesPreestablecidas)
                        DropdownMenuItem(value: unidad, child: Text(unidad)),
                      const DropdownMenuItem(
                        value: _opcionOtroUnidad,
                        child: Text(_opcionOtroUnidad),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _unidadMedidaSeleccionada = value);
                    },
                  ),
                  if (_unidadMedidaSeleccionada == _opcionOtroUnidad) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unidadMedidaController,
                      decoration: const InputDecoration(
                        labelText: 'Especifica la unidad de medida',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _precioUnitarioController,
                    decoration:
                        const InputDecoration(labelText: 'Precio unitario'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (value) {
                      final precio = parseCantidad(value ?? '', esEntero: false);
                      return precio == null ? 'Precio inválido' : null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _seccionFoto(),
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

  Widget _seccionFoto() {
    if (_fotoPath == null) {
      return OutlinedButton.icon(
        onPressed: _tomarFoto,
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Tomar foto'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(_fotoPath!), height: 160, fit: BoxFit.cover),
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Cambiar foto'),
            ),
            TextButton.icon(
              onPressed: _quitarFoto,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Quitar'),
            ),
          ],
        ),
      ],
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
    final precioUnitario =
        parseCantidad(_precioUnitarioController.text, esEntero: false)!;
    final unidadMedida = switch (_unidadMedidaSeleccionada) {
      null => '',
      _opcionOtroUnidad => _unidadMedidaController.text.trim(),
      final unidad => unidad,
    };
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
        unidadMedida: unidadMedida,
        precioUnitario: precioUnitario,
        fotoPath: Value(_fotoPath),
        customValues: customValues,
      );
      await repo.actualizarArticulo(actualizado);
    } else {
      await repo.crearArticulo(
        loteId: widget.loteId,
        noSerie: _noSerieController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        cantidad: cantidad,
        unidadMedida: unidadMedida,
        precioUnitario: precioUnitario,
        fotoPath: _fotoPath,
        customValues: customValues,
      );
    }

    if (context.mounted) Navigator.pop(context);
  }
}
