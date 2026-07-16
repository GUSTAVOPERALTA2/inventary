const express = require('express');
const path = require('path');
const fs = require('fs');
const QRCode = require('qrcode');

const app = express();
// 3000 y 4000 ya estan ocupados en el servidor (172.16.130.10); 4300 es el
// puerto asignado a este servicio. Sigue siendo configurable con PORT si
// hiciera falta cambiarlo mas adelante.
const PORT = process.env.PORT || 4300;
const VERSION_FILE = path.join(__dirname, 'version.json');

// La app BAJAPRO consulta este endpoint (solo cuando detecta wifi) para
// saber si hay una version mas nueva que la instalada. Basta con editar
// version.json y dejar el .apk correspondiente en descargas/ para publicar
// una actualizacion; no hace falta reiniciar el servidor.
app.get('/version', (req, res) => {
  try {
    const version = JSON.parse(fs.readFileSync(VERSION_FILE, 'utf-8'));
    res.json(version);
  } catch (error) {
    console.error('No se pudo leer version.json:', error.message);
    res.status(500).json({ error: 'version.json invalido o no encontrado' });
  }
});

// Sirve los .apk publicados como archivos estaticos, p. ej.
// GET /descargas/app-release.apk
app.use('/descargas', express.static(path.join(__dirname, 'descargas')));

// Pagina con un QR que apunta directo al apkUrl vigente (el mismo que
// devuelve /version): se abre desde una PC/pantalla y la gente lo escanea
// con la camara del telefono para ir directo a la descarga del APK. El QR
// se regenera en cada visita a partir de version.json, asi que si cambia
// la version o la URL no hay que tocar nada aqui.
app.get('/qr', async (req, res) => {
  try {
    const version = JSON.parse(fs.readFileSync(VERSION_FILE, 'utf-8'));
    const qrDataUrl = await QRCode.toDataURL(version.apkUrl, { width: 320 });
    res.send(`<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Descargar BAJAPRO</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 48px; }
    h1 { margin-bottom: 4px; }
    p.version { color: #555; margin-top: 0; }
    img { width: 320px; height: 320px; }
    p.url { color: #888; font-size: 13px; word-break: break-all; }
  </style>
</head>
<body>
  <h1>Escanea para descargar BAJAPRO</h1>
  <p class="version">Version ${version.versionName}</p>
  <img src="${qrDataUrl}" alt="QR para descargar BAJAPRO">
  <p class="url">${version.apkUrl}</p>
</body>
</html>`);
  } catch (error) {
    console.error('No se pudo generar el QR:', error.message);
    res.status(500).send('No se pudo generar el QR: ' + error.message);
  }
});

app.listen(PORT, () => {
  console.log(`Servidor de actualizaciones BAJAPRO escuchando en el puerto ${PORT}`);
});
