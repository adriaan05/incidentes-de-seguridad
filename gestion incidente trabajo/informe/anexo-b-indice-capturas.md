# Anexo B. Índice de capturas de pantalla

Relación de las capturas incluidas en el trabajo, con la máquina en la que se hicieron. Cada captura lleva la hora y, cuando es posible, el nombre de la máquina.

| **ID** | **Captura** | **Máquina** |
|---|---|---|
| [1.1](../capturas/01-prevencion/1.1-cifrado-simetrico-aes256.png) | Cifrado simétrico AES-256 con OpenSSL | VM-KALI |
| [1.2](../capturas/01-prevencion/1.2-rsa-cifrado-asimetrico.png) | Par de claves RSA y cifrado asimétrico | VM-KALI |
| [1.3](../capturas/01-prevencion/1.3-firma-digital.png) | Firma digital: verificación correcta y verificación fallida tras modificar el archivo | VM-KALI |
| [1.4a](../capturas/01-prevencion/1.4a-certificado-jerarquia.png) [1.4b](../capturas/01-prevencion/1.4b-certificado-general.png) [1.4c](../capturas/01-prevencion/1.4c-openssl-sclient.png) | Cadena de certificación de un sitio web (visor del navegador y openssl s_client) | ANFITRIÓN / VM-KALI |
| [1.5](../capturas/01-prevencion/1.5-diffie-hellman.png) | Intercambio de claves Diffie-Hellman con números pequeños | VM-KALI |
| [2.1](../capturas/02-deteccion/2.1-defender-cuarentena.png) | Detección del antivirus: historial de protección | VM-WIN |
| [2.2](../capturas/02-deteccion/2.2-visor-eventos-defender.png) | Evento de Defender en el Visor de eventos (ID 1116/1117) | VM-WIN |
| [2.3](../capturas/02-deteccion/2.3-pfirewall-log.png) | Registro del firewall de Windows (pfirewall.log) | VM-WIN |
| [2.4a](../capturas/02-deteccion/2.4a-evento-4625-powershell.png) [2.4b](../capturas/02-deteccion/2.4b-visor-eventos-seguridad.png) | Registros del sistema operativo: inicios de sesión (4624/4625) | VM-WIN |
| [2.5a](../capturas/02-deteccion/2.5a-kali-wireshark-servidor.png) [2.5b](../capturas/02-deteccion/2.5b-windows-beaconing.png) | Tráfico de red: peticiones periódicas en el servidor y en Wireshark | VM-KALI |
| [2.6](../capturas/02-deteccion/2.6-virustotal-ip.png) | Consulta de reputación de IP en VirusTotal | ANFITRIÓN |
| [2.7](../capturas/02-deteccion/2.7-abuseipdb-ip.png) | Consulta de la misma IP en AbuseIPDB | ANFITRIÓN |
| [2.8](../capturas/02-deteccion/2.8-whois-dig-kali-org.png) | whois y dig sobre un dominio (kali.org) | VM-KALI |
| [3.1](../capturas/03-investigacion/3.1-cabeceras-grep.png) | Análisis de cabeceras del correo con la línea de comandos | VM-KALI |
| [3.2a](../capturas/03-investigacion/3.2a-mxtoolbox-cabecera.png) [3.2b](../capturas/03-investigacion/3.2b-mxtoolbox-spf-dkim.png) [3.2c](../capturas/03-investigacion/3.2c-mxtoolbox-resultado.png) | Análisis de cabeceras con MXToolbox Email Header Analyzer | ANFITRIÓN |
| [3.3](../capturas/03-investigacion/3.3-analisis-estatico-eicar.png) | Análisis estático de la muestra EICAR (file, hash, exiftool) | VM-KALI |
| [3.4](../capturas/03-investigacion/3.4-olevba.png) | Análisis con olevba (muestra EICAR) | VM-KALI |
| [3.5](../capturas/03-investigacion/3.5-virustotal-hash.png) | Consulta del hash de EICAR en VirusTotal (búsqueda por hash) | ANFITRIÓN |
| [3.6](../capturas/03-investigacion/3.6-conexion-proceso.png) | Relación conexión-proceso en el equipo (netstat/TCPView) | VM-WIN |
| [3.7a](../capturas/03-investigacion/3.7a-wireshark-beacon.png) [3.7b](../capturas/03-investigacion/3.7b-wireshark-conversaciones.png) | Análisis de periodicidad y conversaciones en Wireshark | VM-KALI |
| [3.8](../capturas/03-investigacion/3.8-sha256-linux.png) | SHA-256 en Linux y efecto avalancha | VM-KALI |
| [3.9](../capturas/03-investigacion/3.9-sha256-windows.png) | SHA-256 en Windows: coincidencia con el hash de Linux | VM-WIN |
| [3.10](../capturas/03-investigacion/3.10-imagen-forense-dd.png) | Adquisición de una imagen forense y verificación del hash | VM-KALI |
| 3.11 | Volcado de memoria RAM del equipo (no realizado; se explica en el apartado 3.7) | — |
| [4.1a](../capturas/04-respuesta/4.1a-antes-aislamiento.png) [4.1b](../capturas/04-respuesta/4.1b-despues-aislamiento.png) | Aislamiento del equipo infectado | VM-WIN |
| [4.2a](../capturas/04-respuesta/4.2a-regla-firewall.png) [4.2b](../capturas/04-respuesta/4.2b-servidor-sin-peticiones.png) | Bloqueo de la IP maliciosa en el firewall | VM-WIN |
| [4.3](../capturas/04-respuesta/4.3-revocacion-credenciales.png) | Revocación de credenciales comprometidas (usuario de Active Directory) | VM-WIN |
| [4.4](../capturas/04-respuesta/4.4-deteccion-persistencia.png) | Detección de la persistencia (schtasks) | VM-WIN |
| [4.5](../capturas/04-respuesta/4.5-eliminacion-persistencia.png) | Eliminación de la persistencia y análisis de Defender | VM-WIN |
| [4.6](../capturas/04-respuesta/4.6-verificacion-posterior.png) | Verificación posterior a la eliminación (sin restauración de instantánea) | VM-WIN |
| [4.7](../capturas/04-respuesta/4.7-reglas-asr.png) | Reglas ASR de Defender habilitadas | VM-WIN |
| [5.1](../capturas/05-organismos/5.1-incibe-cert.png) | Web de INCIBE-CERT: notificación de incidentes y línea de ayuda 017 | ANFITRIÓN |
| [5.2](../capturas/05-organismos/5.2-ccn-cert.png) | Web del CCN-CERT | ANFITRIÓN |
| [5.3](../capturas/05-organismos/5.3-aepd-brechas.png) | Notificación de brechas en la sede electrónica de la AEPD | ANFITRIÓN |
| [5.4](../capturas/05-organismos/5.4-cert-eu.png) | Web de CERT-EU (equipo internacional de referencia) | ANFITRIÓN |
