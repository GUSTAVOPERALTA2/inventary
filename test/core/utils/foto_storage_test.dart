import 'dart:io';

import 'package:app_inventario/core/utils/foto_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late File origen;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('foto_storage_test');
    origen = File('${tempDir.path}/origen.jpg');
    await origen.writeAsBytes([1, 2, 3, 4]);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('copia la foto a la carpeta de fotos dentro del directorio base',
      () async {
    final ruta = await guardarFotoArticulo(
      origenPath: origen.path,
      directorioBase: tempDir,
    );

    expect(ruta, contains(carpetaFotosArticulos));
    expect(ruta, endsWith('.jpg'));
    expect(await File(ruta).exists(), isTrue);
    expect(await File(ruta).readAsBytes(), [1, 2, 3, 4]);
  });

  test('dos fotos guardadas seguidas obtienen rutas distintas', () async {
    final ruta1 = await guardarFotoArticulo(
      origenPath: origen.path,
      directorioBase: tempDir,
    );
    final ruta2 = await guardarFotoArticulo(
      origenPath: origen.path,
      directorioBase: tempDir,
    );

    expect(ruta1, isNot(equals(ruta2)));
  });
}
