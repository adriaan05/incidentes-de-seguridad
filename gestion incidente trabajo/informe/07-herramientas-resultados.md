# 7. Herramientas utilizadas y resultados obtenidos

Resumen de las herramientas empleadas en las pruebas de laboratorio y de los resultados que se documentan con las capturas.

| **Herramienta** | **Máquina** | **Uso** | **Resultado obtenido** | **Captura** |
|---|---|---|---|---|
| OpenSSL | VM-KALI | Cifrado AES, RSA, firma y verificación | Datos cifrados y recuperados; firma válida y firma inválida tras modificar el archivo | 1.1 a 1.3 |
| Navegador y openssl s_client | ANFITRIÓN / VM-KALI | Cadena de certificación de incibe.es | Jerarquía servidor, CA intermedia y raíz | 1.4 |
| Python | VM-KALI | Diffie-Hellman con números pequeños | Mismo secreto compartido (2) en ambas partes | 1.5 |
| Microsoft Defender | VM-WIN | Detección de EICAR; reglas ASR; escaneo | Detección de EICAR en cuarentena (19/11/2026), eventos 1116/1117 y cuatro reglas ASR activas | 2.1, 2.2, 4.5, 4.7 |
| Visor de eventos / PowerShell | VM-WIN | Revisión de logs de seguridad | Eventos 4625/4624 localizados | 2.4 |
| Firewall de Windows (log) | VM-WIN | Registro de conexiones, regla de bloqueo | Conexiones periódicas registradas; regla de bloqueo aplicada | 2.3, 4.2 |
| Python http.server, tcpdump, Wireshark | VM-KALI | Servidor de pruebas y captura de tráfico | Patrón de beaconing cada \~10 s | 2.5, 3.7 |
| VirusTotal, AbuseIPDB | ANFITRIÓN | OSINT de una IP real, dominios y hash | IP 192.162.199.249: 15/92 motores, AS214351 (Alemania), 2 % en AbuseIPDB; hash de EICAR: 64/66 | 2.6, 2.7, 3.5 |
| whois, dig | VM-KALI | Registro y resolución de un dominio (kali.org) | Fecha de creación, registrador, DNS e IP | 2.8 |
| grep, MXToolbox | VM-KALI / ANFITRIÓN | Análisis de cabeceras del correo de ejemplo | Suplantación detectada (SPF/DKIM/DMARC en fallo) | 3.1, 3.2 |
| file, sha256sum, exiftool, olevba | VM-KALI | Análisis estático de la muestra EICAR | Tipo «EICAR virus test files», hash SHA-256 y metadatos; olevba sin macros ni IOC (es texto) | 3.3, 3.4 |
| netstat, tasklist, TcpClient | VM-WIN | Relación conexión-proceso | Conexión ESTABLISHED asociada a powershell.exe (PID 4824) | 3.6 |
| sha256sum, Get-FileHash | VM-KALI / VM-WIN | Hash SHA-256 y efecto avalancha | Hashes iguales entre sistemas; distintos tras el cambio | 3.8, 3.9 |
| dd, sha256sum | VM-KALI | Imagen forense y verificación de hash | Hash de origen y de copia idénticos | 3.10 (3.11 no realizada) |
| PowerShell, schtasks, cmdlets de Active Directory | VM-WIN | Aislamiento, credenciales, persistencia | Equipo aislado, regla de bloqueo, cuenta revocada, persistencia eliminada | 4.1 a 4.5 |
| PowerShell (verificación) | VM-WIN | Verificación posterior a la eliminación | Tarea inexistente y EICAR ausente del disco | 4.6 |
