# Apartado 2 - Simulación INOFENSIVA de beaconing (VM-WIN). Una petición HTTP cada 10 s a tu propia VM-KALI.
# Ejecutar en PowerShell como administrador. Ctrl+C para parar.
netsh advfirewall set currentprofile logging allowedconnections enable
netsh advfirewall set currentprofile logging droppedconnections enable
netsh advfirewall set currentprofile logging maxfilesize 16384
while ($true) {
    try { Invoke-WebRequest -Uri "http://192.168.56.10:8000/beacon" -UseBasicParsing | Out-Null } catch {}
    Start-Sleep -Seconds 10
}
