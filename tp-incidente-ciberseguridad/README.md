# Gestión de un incidente de ciberseguridad

Trabajo práctico individual: plan completo de prevención, detección, investigación, respuesta, notificación y simulación ante un incidente de **phishing con posible fuga de datos** en una empresa ficticia (*Soluciones Delta, S.L.*, ~100 empleados).

> Caso, personas, IP y dominios **ficticios**. Todas las pruebas se hacen en máquinas virtuales propias y aisladas, con material inofensivo (fichero EICAR, macro que solo muestra un mensaje, tráfico simulado).

## Qué hay en este repositorio

| Carpeta | Contenido |
|---|---|
| [`docs/informe.md`](docs/informe.md) | Informe completo en Markdown (se lee directamente en GitHub) |
| [`docs/`](docs) | Versiones entregables: `.docx` y `.pdf` |
| [`lab/`](lab) | Scripts y ficheros del laboratorio (correo de ejemplo, beaconing simulado, criptografía, hash y forense, respuesta) |
| [`evidence/`](evidence) | Capturas de pantalla (`1.1.png`, `1.2.png`…) y lista de comprobación |

## Contenido del informe

1. Prevención y concienciación (riesgos, normas, plan de formación, cartel de phishing, criptografía)
2. Detección y auditoría (clasificación, herramientas, registros, OSINT, ficha del incidente)
3. Investigación y análisis (evidencias, integridad, correo, malware, conexiones, SHA-256, cadena de custodia)
4. Respuesta y recuperación (procedimiento de seis fases y ciberresiliencia)
5. Notificación y organismos de respuesta (comunicación interna, AEPD, INCIBE-CERT, CCN-CERT, CERT-EU)
6. Simulación de la reunión del equipo de respuesta
7. Herramientas y resultados · 8. Conclusiones · 9. Fuentes · Anexos

## Laboratorio

| Máquina | Papel |
|---|---|
| `VM-WIN` (Windows 10/11, host-only, 192.168.56.20) | Equipo de la víctima |
| `VM-KALI` (Kali/Ubuntu, host-only, 192.168.56.10) | Analista y servidor que simula al atacante |
| Anfitrión | Navegador para OSINT y webs oficiales |

Orden recomendado: `lab/crypto_demo.sh` → `lab/servidor_kali.sh` (Kali) + `lab/beacon.ps1` (Windows) → `lab/hash_forense_demo.sh` → `lab/respuesta_win.ps1`. Haz una **instantánea** de las dos máquinas antes de empezar.

## Capturas

Guarda cada captura en `evidence/` con el número de figura (`1.1.png`…). El informe en Markdown las muestra automáticamente. La lista completa está en [`evidence/README.md`](evidence/README.md).

## Antes de publicar

- Sustituye los campos `[Tu nombre]`, módulo, centro y fecha de los documentos.
- No subas claves privadas, volcados de memoria, capturas de red ni datos reales (el `.gitignore` ya bloquea las extensiones habituales).
- Al ser un trabajo evaluable, considera usar un repositorio **privado** y darle acceso a tu profesor.
