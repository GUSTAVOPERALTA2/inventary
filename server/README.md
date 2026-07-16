# Servidor de actualizaciones de BAJAPRO

Servidor mínimo que la app consulta (solo cuando el dispositivo tiene wifi)
para saber si hay una versión más nueva del APK disponible. No guarda datos
de los dispositivos ni de los lotes/artículos — la app sigue funcionando
100% offline para todo lo demás; esto es únicamente el chequeo de versión.

Este servidor está pensado para correr en **172.16.130.10, puerto 4300**
(3000 y 4000 ya están ocupados por otros servicios en esa máquina). Tanto
`server/version.json` como `lib/app.dart` (`_endpointVersion`) ya apuntan
ahí — si la IP o el puerto cambiaran, hay que actualizar ambos y volver a
generar el APK.

## Primera vez: dejarlo instalado en 172.16.130.10 (Windows)

Node.js y git ya están instalados en esa máquina, así que solo hace falta
traer el código y levantar el servicio.

1. **Traer el código.** Conéctate a 172.16.130.10 (RDP o como administren
   esa máquina normalmente) y clona el repo (o `git pull` si ya existe):

   ```powershell
   git clone https://github.com/GUSTAVOPERALTA2/inventary.git C:\BAJAPRO
   cd C:\BAJAPRO\server
   ```

   Para futuras actualizaciones del propio servidor (no del APK, sino de
   `server.js`/`version.json` si cambian), basta con `git pull` en esa
   misma carpeta.

2. **Instalar dependencias:**

   ```powershell
   npm install
   ```

3. **Dejarlo corriendo permanentemente con pm2** (para que sobreviva a
   cerrar la sesión y a reinicios de la máquina):

   ```powershell
   npm install -g pm2
   npm install -g pm2-windows-startup
   pm2-startup install

   pm2 start server.js --name bajapro-updates
   pm2 save
   ```

   Con esto, `pm2 start`/`pm2 save` deja el proceso registrado para que
   arranque solo la próxima vez que la máquina se reinicie. Comandos útiles
   después:

   ```powershell
   pm2 status              # ver si sigue corriendo
   pm2 logs bajapro-updates  # ver el log en vivo
   pm2 restart bajapro-updates  # tras cambiar server.js o version.json
   ```

4. **Abrir el puerto 4300 en el firewall de Windows** (si no está ya
   abierto), para que los teléfonos en la red local puedan llegar a él:

   ```powershell
   netsh advfirewall firewall add rule name="BAJAPRO updates" dir=in action=allow protocol=TCP localport=4300
   ```

5. **Probar desde la propia máquina y desde otra en la red:**

   ```powershell
   curl http://localhost:4300/version
   curl http://172.16.130.10:4300/version
   ```

   Si el segundo falla pero el primero funciona, es el firewall (paso 4) o
   que 172.16.130.10 no es la IP real de esa máquina (confirmar con
   `ipconfig`).

## Cómo publicar una actualización (de aquí en adelante)

La forma rápida: un solo comando desde la máquina de desarrollo, sin RDP
ni acceder por red a 172.16.130.10 (ver `POST /upload` más abajo).

1. La primera vez, consigue el token de subida: conéctate una vez a
   172.16.130.10 y mira `C:\BAJAPRO\server\upload_token.txt` (se genera
   solo, la primera vez que arranca el servidor). Guárdalo en tu máquina
   de desarrollo, por ejemplo como variable de entorno:

   ```powershell
   $env:BAJAPRO_UPLOAD_TOKEN = "el-token-que-copiaste"
   ```

2. Desde la raíz del proyecto, en la máquina de desarrollo:

   ```powershell
   flutter build apk --release
   .\publicar_actualizacion.ps1 -VersionCode 3 -VersionName "1.1.0" -Notas "Permite renombrar y eliminar lotes"
   ```

   Esto sube el APK y reescribe `version.json` en el servidor en un solo
   paso — no hace falta copiar el archivo a mano ni editar JSON. El
   `VersionCode` debe ser mayor al anterior (coincide con el número
   después del `+` en `pubspec.yaml`, ej. `1.0.1+2` → `-VersionCode 2`).

3. No hace falta reiniciar el servidor ni hacer `pm2 restart`:
   `version.json` y los archivos de `descargas/` se leen en cada consulta.

### Alternativa manual (sin el script)

Si prefieres no usar el script, sigue funcionando copiar el archivo a
mano: copia `build/app/outputs/flutter-apk/app-release.apk` a
`C:\BAJAPRO\server\descargas\` (por RDP o red compartida) y edita
`version.json` ahí mismo con los mismos campos (`versionCode`,
`versionName`, `apkUrl`, `notas`).

## Endpoints

- `GET /version` → JSON con `versionCode`, `versionName`, `apkUrl`, `notas`.
- `GET /descargas/<archivo>` → sirve el archivo tal cual (estático).
- `GET /qr` → página con un código QR que apunta directo al `apkUrl`
  vigente (se regenera solo a partir de `version.json`, siempre actualizado).
  Ábrela desde una PC/pantalla (`http://172.16.130.10:4300/qr`) para que
  cada quien la escanee con la cámara del teléfono y descargue el APK sin
  tener que escribir la URL a mano.
- `POST /upload?token=...` → sube el `.apk` (campo `apk`,
  multipart/form-data) y, si vienen `versionCode`/`versionName`/`notas`,
  reescribe `version.json` en la misma llamada. Requiere el token de
  `upload_token.txt` (generado solo, la primera vez que arranca el
  servidor). Pensado para usarse vía `publicar_actualizacion.ps1`, no a
  mano.

## Nota sobre HTTPS

Este servidor corre en HTTP plano, pensado para uso dentro de la red local
de la propiedad. La app está configurada para permitir tráfico HTTP sin
cifrar únicamente para este propósito (ver
`android/app/src/main/AndroidManifest.xml`, `usesCleartextTraffic`). No
expongas este servidor directamente a internet sin agregar HTTPS.
