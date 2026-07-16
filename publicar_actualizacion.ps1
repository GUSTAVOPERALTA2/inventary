<#
.SYNOPSIS
  Publica una actualizacion de BAJAPRO en un solo paso: sube el APK ya
  compilado al servidor y actualiza version.json, sin necesitar RDP ni
  acceso por red compartida a la maquina del servidor.

.EXAMPLE
  .\publicar_actualizacion.ps1 -VersionCode 3 -VersionName "1.1.0" -Notas "Permite renombrar y eliminar lotes" -Token XXXX

.NOTES
  El token se genera solo la primera vez que corre el servidor (queda en
  server\upload_token.txt, en la maquina del servidor, no en este repo).
  Consiguelo una vez (por RDP) y guardalo en la variable de entorno
  BAJAPRO_UPLOAD_TOKEN, o pasalo cada vez con -Token.
#>
param(
    [Parameter(Mandatory=$true)][string]$VersionCode,
    [Parameter(Mandatory=$true)][string]$VersionName,
    [string]$Notas = "",
    [string]$Token = $env:BAJAPRO_UPLOAD_TOKEN,
    [string]$ApkPath = "build\app\outputs\flutter-apk\app-release.apk",
    [string]$ServerUrl = "http://172.16.130.10:4300"
)

if (-not $Token) {
    Write-Error "Falta el token. Pasalo con -Token o define `$env:BAJAPRO_UPLOAD_TOKEN (ver server\upload_token.txt en el servidor)."
    exit 1
}

if (-not (Test-Path $ApkPath)) {
    Write-Error "No se encontro el APK en '$ApkPath'. Corre 'flutter build apk --release' primero."
    exit 1
}

$uri = "$ServerUrl/upload?token=$Token"
$form = @{
    apk         = Get-Item $ApkPath
    versionCode = $VersionCode
    versionName = $VersionName
    notas       = $Notas
}

Write-Host "Subiendo $ApkPath a $ServerUrl ..."
$respuesta = Invoke-RestMethod -Uri $uri -Method Post -Form $form
$respuesta | ConvertTo-Json
