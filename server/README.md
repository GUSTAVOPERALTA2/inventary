# Servidor de actualizaciones de BAJAPRO

Servidor mínimo que la app consulta (solo cuando el dispositivo tiene wifi)
para saber si hay una versión más nueva del APK disponible. No guarda datos
de los dispositivos ni de los lotes/artículos — la app sigue funcionando
100% offline para todo lo demás; esto es únicamente el chequeo de versión.

## Cómo correrlo

```bash
cd server
npm install
npm start
```

Por defecto escucha en el puerto `4000`. Para usar otro puerto:

```bash
PORT=8080 npm start
```

Para dejarlo corriendo de forma permanente en un servidor Windows, la forma
más simple es con [pm2](https://pm2.keymetrics.io/) (`npm install -g pm2`,
luego `pm2 start server.js --name bajapro-updates`) o registrándolo como
tarea programada/servicio de Windows.

## Cómo publicar una actualización

1. Genera el nuevo APK (`flutter build apk --release` en la carpeta del
   proyecto) y copia `build/app/outputs/flutter-apk/app-release.apk` a la
   carpeta `descargas/` de este servidor (sobrescribiendo el anterior).
2. Edita `version.json`:
   - `versionCode`: súbelo en 1 respecto al anterior (debe ser mayor al
     `versionCode` que trae el APK instalado — coincide con el número
     después del `+` en `pubspec.yaml`, ej. `1.0.1+2` → `versionCode: 2`).
   - `versionName`: el nombre de versión visible (ej. `"1.0.1"`).
   - `apkUrl`: la URL completa donde quedará accesible el APK — debe
     apuntar a la IP o nombre de esta máquina en la red local, por ejemplo
     `http://192.168.1.50:4000/descargas/app-release.apk`. Para saber la IP
     de esta máquina en la red: `ipconfig` (Windows) y busca la dirección
     IPv4 del adaptador de red conectado.
   - `notas`: texto corto opcional que se le muestra al usuario en el
     diálogo de actualización.
3. No hace falta reiniciar el servidor: `version.json` se lee en cada
   consulta a `/version`.

## Endpoints

- `GET /version` → JSON con `versionCode`, `versionName`, `apkUrl`, `notas`.
- `GET /descargas/<archivo>` → sirve el archivo tal cual (estático).

## Nota sobre HTTPS

Este servidor corre en HTTP plano, pensado para uso dentro de la red local
de la propiedad. La app está configurada para permitir tráfico HTTP sin
cifrar únicamente para este propósito (ver
`android/app/src/main/AndroidManifest.xml`, `usesCleartextTraffic`). No
expongas este servidor directamente a internet sin agregar HTTPS.
