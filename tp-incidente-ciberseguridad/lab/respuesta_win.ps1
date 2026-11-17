# Apartado 4 - Prácticas de respuesta (VM-WIN, PowerShell administrador). SOLO en el laboratorio.
# Ejecuta cada bloque por separado, haciendo la captura correspondiente.

# 4.1 Aislamiento
ping 192.168.56.10 -n 3
Get-NetAdapter
Disable-NetAdapter -Name "Ethernet" -Confirm:$false
ping 192.168.56.10 -n 3
# Enable-NetAdapter -Name "Ethernet"      # volver a habilitar tras la prueba

# 4.2 Bloqueo de la IP "maliciosa"
New-NetFirewallRule -DisplayName "IR-INC001 Bloqueo C2" -Direction Outbound -RemoteAddress 192.168.56.10 -Action Block
Get-NetFirewallRule -DisplayName "IR-INC001*" | Format-Table DisplayName,Direction,Action,Enabled

# 4.3 Revocación de credenciales (usuario de laboratorio)
net user usuario_victima Passw0rd!Lab /add
Disable-LocalUser -Name "usuario_victima"
net user usuario_victima "N0va-Clave_Segura#2026"
Get-LocalUser usuario_victima | Format-List Name,Enabled,PasswordLastSet

# 4.4 / 4.5 Persistencia inofensiva: crear, detectar, eliminar
schtasks /create /tn "ActualizacionLab" /tr "powershell.exe -Command Start-Sleep 1" /sc onlogon
schtasks /query /tn "ActualizacionLab" /v /fo list
schtasks /delete /tn "ActualizacionLab" /f
schtasks /query /tn "ActualizacionLab"
Start-MpScan -ScanType QuickScan; Get-MpThreatDetection

# 4.7 Reglas ASR de Defender
Add-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A -AttackSurfaceReductionRules_Actions Enabled
Add-MpPreference -AttackSurfaceReductionRules_Ids BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550 -AttackSurfaceReductionRules_Actions Enabled
Get-MpPreference | Select-Object AttackSurfaceReductionRules_Ids,AttackSurfaceReductionRules_Actions
