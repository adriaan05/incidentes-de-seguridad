<#
.SYNOPSIS
  Simula el "beaconing" de un malware: una petición HTTP periódica a un servidor.
.DESCRIPTION
  Apartado 2.4 (práctica A). Son peticiones HTTP inocuas contra VM-KALI.
  Ejecutar en VM-WIN (PowerShell). Parar con Ctrl+C.
.EXAMPLE
  .\beacon.ps1 -Servidor 192.168.68.107
#>
param(
  [string]$Servidor  = "192.168.68.107",   # IP de VM-KALI
  [int]   $Puerto    = 8000,
  [int]   $Intervalo = 10                  # segundos entre peticiones
)

$uri = "http://${Servidor}:${Puerto}/beacon"
Write-Host "Beaconing a $uri cada $Intervalo s. Ctrl+C para parar."
while ($true) {
  try { Invoke-WebRequest -Uri $uri -UseBasicParsing | Out-Null } catch {}
  Start-Sleep -Seconds $Intervalo
}
