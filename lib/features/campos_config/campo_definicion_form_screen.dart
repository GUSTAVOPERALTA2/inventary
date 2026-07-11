import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/campo_tipo.dart';
import '../../data/repositories/campos_config_repository.dart';

/// Alta de una definición de campo configurable. No hay edición: el
/// bloque solo contempla crear y eliminar (borrado lógico).
class CampoDefinicionFormScreen extends StatefulWidget {
  const CampoDefinicionFormScreen({super.key});

  @override
  State<CampoDefinicionFormScreen> createState() =>
      _CampoDefinicionFormScreenState();
}

class _CampoDefinicionFormScreenState
    extends State<CampoDefinicionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _opcionesController = TextEditingController();
  CampoTipo _tipo = CampoTipo.texto;

  @override
  void dispose() {
    _nombreController.dispose();
    _opcionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo campo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del campo'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CampoTipo>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: CampoTipo.values
                  .map((tipo) =>
                      DropdownMenuItem(value: tipo, child: Text(tipo.label)))
                  .toList(),
              onChanged: (value) => setState(() => _tipo = value!),
            ),
            if (_tipo == CampoTipo.lista) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _opcionesController,
                decoration: const InputDecoration(
                  labelText: 'Opciones (separadas por coma)',
                  hintText: 'Ej: Nuevo, Usado, Dañado',
                ),
                validator: (value) {
                  if (_tipo != CampoTipo.lista) return null;
                  final opciones = _parseOpciones(value ?? '');
                  return opciones.isEmpty
                      ? 'Agrega al menos una opción'
                      : null;
                },
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _guardar(context),
              child: const Text('Crear campo'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _parseOpciones(String texto) => texto
      .split(',')
      .map((opcion) => opcion.trim())
      .where((opcion) => opcion.isNotEmpty)
      .toList();

  Future<void> _guardar(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<CamposConfigRepository>();
    final orden = await repo.siguienteOrden();
    await repo.crearDefinicion(
      nombre: _nombreController.text.trim(),
      tipo: _tipo,
      opciones: _tipo == CampoTipo.lista
          ? _parseOpciones(_opcionesController.text)
          : null,
      orden: orden,
    );

    if (context.mounted) Navigator.pop(context);
  }
}
