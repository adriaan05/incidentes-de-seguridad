# Gestión de un incidente de ciberseguridad

Trabajo práctico individual: gestión de un incidente de phishing con ejecución de malware y posible fuga de datos de clientes en **Soluciones Delta, S.L.** (empresa ficticia de unos 100 empleados). Actúo como responsable del equipo de ciberseguridad y recorro el ciclo completo: prevención, detección, investigación, respuesta y recuperación, notificación y simulación de una reunión del equipo de respuesta.

| | |
|---|---|
| **Alumno/a** | Adrian Fuente |
| **Módulo / asignatura** | Incidentes de ciberseguridad |
| **Fecha de entrega** | 3/12/2026 |

> **Aviso.** Todas las pruebas prácticas se realizaron exclusivamente en máquinas virtuales propias y entornos autorizados. La empresa, las personas, los dominios `.example` y las IP de documentación del caso son ficticios. No se usó malware real (solo el fichero de prueba EICAR y tráfico inocuo).

## Informe

El trabajo está redactado en esta misma página de GitHub, dividido por apartados. También hay una copia en PDF y en Word en [`informe/`](informe/).

| Apartado | Contenido | Peso |
|---|---|---|
| [Introducción](informe/00-introduccion.md) | Resumen del caso, cronología y entorno de laboratorio | — |
| [1. Prevención y concienciación](informe/01-prevencion.md) | Riesgos, normas, plan de formación, cartel y guía de phishing, criptografía (AES, RSA, hash, firma, PKI, Diffie-Hellman) | 15 % |
| [2. Detección y auditoría](informe/02-deteccion-auditoria.md) | Clasificación, sistemas afectados, herramientas, registros, OSINT y ficha del incidente | 20 % |
| [3. Investigación y análisis](informe/03-investigacion-analisis.md) | Evidencias, integridad, correo, archivo, conexiones, SHA-256 y cadena de custodia | 20 % |
| [4. Respuesta y recuperación](informe/04-respuesta-recuperacion.md) | Procedimiento, práctica de laboratorio y ciberresiliencia | 20 % |
| [5. Notificación y organismos](informe/05-notificacion-cert.md) | Comunicación interna, AEPD y CERT/CSIRT | 15 % |
| [6. Simulación](informe/06-simulacion.md) | Reunión del equipo de respuesta con cuatro giros | 10 % |
| [7. Herramientas y resultados](informe/07-herramientas-resultados.md) | Herramientas usadas y resultados obtenidos | — |
| [8. Conclusiones](informe/08-conclusiones.md) | Conclusiones y valoración del trabajo práctico | — |
| [9. Fuentes](informe/09-fuentes.md) | Normativa, estándares y organismos consultados | — |
| [Anexo A](informe/anexo-a-correo-ejemplo.md) | Correo de ejemplo (`phishing_sample.eml`) | — |
| [Anexo B](informe/anexo-b-indice-capturas.md) | Índice de las capturas de pantalla | — |

## Estructura del repositorio

```text
.
├── README.md
├── informe/        Informe por apartados en Markdown (+ copia en PDF y Word)
├── capturas/       Capturas de pantalla por apartado (01-prevencion … 05-organismos)
├── scripts/
│   ├── kali/       crypto_demo.sh, hash_forense_demo.sh, servidor_kali.sh
│   └── windows/    beacon.ps1, respuesta_win.ps1
├── muestras/       phishing_sample.eml (correo ficticio e inofensivo)
└── docs/           entorno-laboratorio.md (máquinas, IP, herramientas y limitaciones)
```

## Entorno

| Máquina | Sistema | IP |
|---|---|---|
| VM-WIN | Windows Server 2022 (evaluación), SRV-DC01, dominio EMPRESA | 192.168.68.102 |
| VM-KALI | Kali Linux | 192.168.68.107 |

Más detalle en [`docs/entorno-laboratorio.md`](docs/entorno-laboratorio.md).

## Scripts

Todos son para uso **solo en el laboratorio**.

| Script | Máquina | Qué hace | Apartado |
|---|---|---|---|
| `scripts/kali/crypto_demo.sh` | VM-KALI | Cifrado simétrico y asimétrico, firma, cadena de certificados y Diffie-Hellman | 1.5 |
| `scripts/kali/servidor_kali.sh <interfaz> <ip_victima>` | VM-KALI | Servidor HTTP (puerto 8000) y captura con tcpdump en `~/beacon.pcap` | 2.4 |
| `scripts/windows/beacon.ps1` | VM-WIN | Simula el beaconing: una petición HTTP cada 10 s a VM-KALI | 2.4 |
| `scripts/kali/hash_forense_demo.sh` | VM-KALI | SHA-256, efecto avalancha e imagen forense con `dd` | 3.6 y 3.7 |
| `scripts/windows/respuesta_win.ps1 -Paso <paso>` | VM-WIN | Aislar, bloquear, revocar credenciales, persistencia, reglas ASR y limpieza | 4.1 a 4.7 |

Ejemplo de uso:

```bash
# VM-KALI
./scripts/kali/servidor_kali.sh eth0 192.168.68.102
```

```powershell
# VM-WIN (PowerShell como administrador)
.\scripts\windows\beacon.ps1 -Servidor 192.168.68.107
.\scripts\windows\respuesta_win.ps1 -Paso Bloquear
.\scripts\windows\respuesta_win.ps1 -Paso Limpiar
```

## Notas

- Los ficheros pesados o sensibles de las pruebas (`*.img`, `*.pcap`, claves `*.pem`, cifrados, `eicar*`) no se suben al repositorio (ver `.gitignore`).
- Limitaciones conocidas del laboratorio (licencia de evaluación, sin instantánea previa, sin Word, sin volcado de RAM): ver [`docs/entorno-laboratorio.md`](docs/entorno-laboratorio.md) y el apartado [8](informe/08-conclusiones.md).
