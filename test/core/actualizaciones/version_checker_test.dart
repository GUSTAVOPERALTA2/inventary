import 'package:app_inventario/core/actualizaciones/version_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

Future<PackageInfo> _infoConVersion(String buildNumber) async {
  return PackageInfo(
    appName: 'BAJAPRO',
    packageName: 'com.viceroycabos.inventario',
    version: '1.0.0',
    buildNumber: buildNumber,
  );
}

final _endpoint = Uri.parse('http://192.168.1.100:4000/version');

void main() {
  test('sin wifi no consulta el servidor y devuelve null', () async {
    var seLlamoHttp = false;

    final resultado = await buscarActualizacionDisponible(
      endpoint: _endpoint,
      obtenerConectividad: () async => [ConnectivityResult.mobile],
      obtenerHttp: (uri) async {
        seLlamoHttp = true;
        return http.Response('{}', 200);
      },
      obtenerInfoPaquete: () => _infoConVersion('1'),
    );

    expect(resultado, isNull);
    expect(seLlamoHttp, isFalse);
  });

  test('sin conexion (lista vacia) tampoco consulta el servidor', () async {
    final resultado = await buscarActualizacionDisponible(
      endpoint: _endpoint,
      obtenerConectividad: () async => [ConnectivityResult.none],
      obtenerHttp: (uri) async => http.Response('{}', 200),
      obtenerInfoPaquete: () => _infoConVersion('1'),
    );

    expect(resultado, isNull);
  });

  test('con wifi y una version remota mas nueva devuelve sus datos',
      () async {
    final resultado = await buscarActualizacionDisponible(
      endpoint: _endpoint,
      obtenerConectividad: () async => [ConnectivityResult.wifi],
      obtenerHttp: (uri) async {
        expect(uri, _endpoint);
        return http.Response(
          '{"versionCode": 3, "versionName": "1.2.0", '
          '"apkUrl": "http://192.168.1.100:4000/descargas/app-release.apk", '
          '"notas": "Corrige un bug"}',
          200,
        );
      },
      obtenerInfoPaquete: () => _infoConVersion('2'),
    );

    expect(resultado, isNotNull);
    expect(resultado!.versionCode, 3);
    expect(resultado.versionName, '1.2.0');
    expect(
      resultado.apkUrl,
      'http://192.168.1.100:4000/descargas/app-release.apk',
    );
    expect(resultado.notas, 'Corrige un bug');
  });

  test('con wifi pero la version remota es igual a la actual, devuelve null',
      () async {
    final resultado = await buscarActualizacionDisponible(
      endpoint: _endpoint,
      obtenerConectividad: () async => [ConnectivityResult.wifi],
      obtenerHttp: (uri) async => http.Response(
        '{"versionCode": 2, "versionName": "1.0.0", "apkUrl": "http://x/a.apk"}',
        200,
      ),
      obtenerInfoPaquete: () => _infoConVersion('2'),
    );

    expect(resultado, isNull);
  });

  test(
      'con wifi pero la version remota es mas vieja que la actual, devuelve null',
      () async {
    final resultado = await buscarActualizacionDisponible(
      endpoint: _endpoint,
      obtenerConectividad: () async => [ConnectivityResult.wifi],
      obtenerHttp: (uri) async => http.Response(
        '{"versionCode": 1, "versionName": "0.9.0", "apkUrl": "http://x/a.apk"}',
        200,
      ),
      obtenerInfoPaquete: () => _infoConVersion('5'),
    );

    expect(resultado, isNull);
  });

  test('servidor inalcanzable (excepcion) no truena, devuelve null',
      () async {
    final resultado = await buscarActualizacionDisponible(
      endpoint: _endpoint,
      obtenerConectividad: () async => [ConnectivityResult.wifi],
      obtenerHttp: (uri) async => throw Exception('Connection refused'),
      obtenerInfoPaquete: () => _infoConVersion('1'),
    );

    expect(resultado, isNull);
  });

  test('respuesta con status distinto de 200 devuelve null', () async {
    final resultado = await buscarActualizacionDisponible(
      endpoint: _endpoint,
      obtenerConectividad: () async => [ConnectivityResult.wifi],
      obtenerHttp: (uri) async => http.Response('Not Found', 404),
      obtenerInfoPaquete: () => _infoConVersion('1'),
    );

    expect(resultado, isNull);
  });

  test('JSON invalido no truena, devuelve null', () async {
    final resultado = await buscarActualizacionDisponible(
      endpoint: _endpoint,
      obtenerConectividad: () async => [ConnectivityResult.wifi],
      obtenerHttp: (uri) async => http.Response('esto no es json', 200),
      obtenerInfoPaquete: () => _infoConVersion('1'),
    );

    expect(resultado, isNull);
  });
}
