# Entorno de laboratorio

Todas las pruebas se realizaron en máquinas virtuales propias, sin tocar equipos ni redes ajenos.

| Máquina | Sistema | Nombre de equipo | IP | Papel |
|---|---|---|---|---|
| VM-WIN | Windows Server 2022 Datacenter (versión de evaluación) con Active Directory | SRV-DC01 (dominio EMPRESA) | 192.168.68.102 | Equipo de la víctima y servidor de dominio |
| VM-KALI | Kali Linux | kali (usuario `adrian`) | 192.168.68.107 | Estación del analista y servidor que simula al atacante |
| Anfitrión | Equipo real del alumno | — | — | Solo para consultas OSINT y capturas de webs públicas |

## Herramientas

- **Kali:** OpenSSL, tcpdump, Wireshark, Python 3 (`http.server`), exiftool, oletools (olevba), whois, dig, dd, sha256sum.
- **Windows:** Microsoft Defender, Visor de eventos, PowerShell (cmdlets de Active Directory y de firewall), `schtasks`, `netstat`.
- **Web (OSINT):** VirusTotal, AbuseIPDB, MXToolbox Email Header Analyzer.

## Limitaciones conocidas

- La licencia de evaluación de Windows Server caducó durante las pruebas y la máquina se apagaba sola cada cierto tiempo, por lo que algunas pruebas se repitieron.
- No existía una instantánea previa de VM-WIN: la recuperación (4.6) se documenta como verificación posterior a la eliminación.
- No se pudo crear un documento con macro (sin Word ni LibreOffice): el análisis estático se hizo con el fichero de prueba EICAR.
- No se realizó el volcado de memoria RAM (captura opcional 3.11); se explica cómo se haría en el apartado 3.7.

## Datos ficticios y seguridad

- La empresa, las personas, los dominios `.example` y las IP de documentación (203.0.113.0/24 y 198.51.100.0/24) son ficticios.
- No se usó malware real: solo el fichero de prueba EICAR y tráfico HTTP inocuo.
- El único indicador real consultado (192.162.199.249) se miró solo en webs de OSINT, sin conectarse a él.
