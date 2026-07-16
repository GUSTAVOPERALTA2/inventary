import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Datos de la última versión publicada en el servidor local de
/// actualizaciones (ver `server/README.md`).
class InfoVersionRemota {
  const InfoVersionRemota({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    this.notas,
  });

  final int versionCode;
  final String versionName;
  final String apkUrl;
  final String? notas;

  factory InfoVersionRemota.fromJson(Map<String, dynamic> json) {
    return InfoVersionRemota(
      versionCode: json['versionCode'] as int,
      versionName: json['versionName'] as String,
      apkUrl: json['apkUrl'] as String,
      notas: json['notas'] as String?,
    );
  }
}

Future<List<ConnectivityResult>> _obtenerConectividadReal() =>
    Connectivity().checkConnectivity();

/// Revisa si hay una versión más nueva publicada en [endpoint], pero solo
/// si el dispositivo está conectado a wifi (nunca por datos móviles, y
/// nunca sin conexión). Cualquier fallo — sin wifi, servidor inalcanzable,
/// respuesta inválida, timeout — se traga en silencio devolviendo `null`:
/// esta función jamás debe interrumpir ni bloquear el uso normal, offline,
/// de la app.
Future<InfoVersionRemota?> buscarActualizacionDisponible({
  required Uri endpoint,
  Future<List<ConnectivityResult>> Function() obtenerConectividad =
      _obtenerConectividadReal,
  Future<http.Response> Function(Uri) obtenerHttp = http.get,
  Future<PackageInfo> Function() obtenerInfoPaquete =
      PackageInfo.fromPlatform,
}) async {
  try {
    final conectividad = await obtenerConectividad();
    if (!conectividad.contains(ConnectivityResult.wifi)) return null;

    final respuesta = await obtenerHttp(
      endpoint,
    ).timeout(const Duration(seconds: 5));
    if (respuesta.statusCode != 200) return null;

    final json = jsonDecode(respuesta.body) as Map<String, dynamic>;
    final remota = InfoVersionRemota.fromJson(json);

    final infoActual = await obtenerInfoPaquete();
    final versionCodeActual = int.tryParse(infoActual.buildNumber) ?? 0;

    if (remota.versionCode <= versionCodeActual) return null;
    return remota;
  } catch (_) {
    return null;
  }
}
