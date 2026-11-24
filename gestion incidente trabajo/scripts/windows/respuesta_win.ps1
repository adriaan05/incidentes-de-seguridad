<#
.SYNOPSIS
  Pasos de respuesta al incidente en el laboratorio (apartados 4.1 a 4.7 del informe).
.DESCRIPTION
  Ejecutar en VM-WIN con PowerShell como administrador, UN PASO CADA VEZ.
  Solo para el laboratorio. El paso "Limpiar" deshace los cambios de la prueba.
.EXAMPLE
  .\respuesta_win.ps1 -Paso Aislar
  .\respuesta_win.ps1 -Paso Limpiar
#>
param(
  [Parameter(Mandatory)]
  [ValidateSet('Aislar','Bloquear','Credenciales','Persistencia','Asr','Limpiar')]
  [string]$Paso,
  [string]$Kali      = "192.168.68.107",
  [string]$Adaptador = "Ethernet"
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw "Ejecuta PowerShell como administrador."
}
$fecha = { Get-Date -Format "dd/MM/yyyy HH:mm:ss" }

switch ($Paso) {

  'Aislar' {            # 4.1 Aislamiento del equipo
    ping $Kali -n 3
    Get-NetAdapter
    Disable-NetAdapter -Name $Adaptador -Confirm:$false
    ping $Kali -n 3
    & $fecha
    Write-Host "Para restaurar: .\respuesta_win.ps1 -Paso Limpiar"
  }

  'Bloquear' {          # 4.2 Bloqueo de conexiones maliciosas
    New-NetFirewallRule -DisplayName "IR-INC001 Bloqueo C2" -Direction Outbound `
        -RemoteAddress $Kali -Action Block | Out-Null
    Get-NetFirewallRule -DisplayName "IR-INC001*" |
        Format-Table DisplayName,Direction,Action,Enabled
    & $fecha
  }

  'Credenciales' {      # 4.3 Revocación de credenciales (usuario de prueba de Active Directory)
    # Contraseñas FICTICIAS de laboratorio
    New-ADUser -Name "usuario_victima" -SamAccountName usuario_victima `
        -AccountPassword (ConvertTo-SecureString "Passw0rd!Lab" -AsPlainText -Force) -Enabled $true
    Disable-ADAccount -Identity usuario_victima
    Set-ADAccountPassword -Identity usuario_victima -Reset `
        -NewPassword (ConvertTo-SecureString "N0va-Clave_Segura#2026" -AsPlainText -Force)
    Get-ADUser usuario_victima -Properties Enabled,PasswordLastSet |
        Format-List Name,Enabled,PasswordLastSet
    & $fecha
  }

  'Persistencia' {      # 4.4 y 4.5 Detección y eliminación de la persistencia
    schtasks /create /tn "ActualizacionLab" /tr "powershell.exe -Command Start-Sleep 1" /sc onlogon
    schtasks /query /tn "ActualizacionLab" /v /fo list
    reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run
    Read-Host "Captura 4.4 hecha. Pulsa Intro para eliminar la tarea"
    schtasks /delete /tn "ActualizacionLab" /f
    schtasks /query /tn "ActualizacionLab"        # debe dar error: no existe
    Start-MpScan -ScanType QuickScan
    Get-MpThreatDetection | Select-Object -First 3 InitialDetectionTime,ThreatID,Resources
    & $fecha
  }

  'Asr' {               # 4.7 Reglas de reducción de superficie de ataque (Defender)
    Add-MpPreference -AttackSurfaceReductionRules_Ids `
        D4F940AB-401B-4EFC-AADC-AD5F3C50688A,BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550,92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B,D3E037E1-3EB8-44C8-A917-57927947596D `
        -AttackSurfaceReductionRules_Actions Enabled,Enabled,Enabled,Enabled
    $p = Get-MpPreference
    $i = 0
    $p.AttackSurfaceReductionRules_Ids | ForEach-Object {
      "{0}  ->  acción {1}" -f $_, $p.AttackSurfaceReductionRules_Actions[$i]; $i++
    }
    & $fecha
  }

  'Limpiar' {           # Deshace los cambios de las pruebas
    Enable-NetAdapter -Name $Adaptador -ErrorAction SilentlyContinue
    Remove-NetFirewallRule -DisplayName "IR-INC001*" -ErrorAction SilentlyContinue
    schtasks /delete /tn "ActualizacionLab" /f 2>$null
    Remove-ADUser -Identity usuario_victima -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Limpieza hecha: adaptador habilitado, regla y tarea eliminadas, usuario de prueba borrado."
  }
}
