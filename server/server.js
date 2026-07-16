const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 4000;
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

app.listen(PORT, () => {
  console.log(`Servidor de actualizaciones BAJAPRO escuchando en el puerto ${PORT}`);
});
