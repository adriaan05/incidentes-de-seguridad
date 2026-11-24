# Introducción, alcance y entorno de pruebas

## Resumen ejecutivo del caso

**Soluciones Delta, S.L.** (empresa ficticia creada para este trabajo; unos 100 empleados, servicios de gestión administrativa para clientes) ha sufrido un incidente de ciberseguridad. Varios empleados recibieron un correo que aparentaba proceder de Recursos Humanos. Uno de ellos abrió el documento adjunto y ejecutó un archivo malicioso. Después, el departamento de informática detectó conexiones salientes hacia IP externas, alertas del antivirus e intentos de acceso a carpetas compartidas. Se sospecha que se han podido extraer datos personales de clientes. La empresa no dispone de procedimientos formales de prevención ni de respuesta a incidentes.

En este documento actúo como **responsable del equipo de ciberseguridad**. El trabajo recorre el ciclo completo de gestión del incidente: prevención, detección, investigación, respuesta y recuperación, notificación y simulación de una reunión del equipo de respuesta. Sigue como referencia metodológica el ciclo de NIST SP 800-61 (preparación; detección y análisis; contención, erradicación y recuperación; actividad posterior al incidente) y la norma ISO/IEC 27035.

## Cronología supuesta del incidente (datos ficticios)

| **Hora (16/11/2026)** | **Evento** |
|---|---|
| 09:12 | 14 empleados reciben el correo «Actualización de nómina - acción requerida», remitente aparente: Recursos Humanos. |
| 09:31 | Un empleado de Administración (equipo WS-ADM-07) abre el adjunto *Nomina_Noviembre_2026.docm* y habilita las macros. Se ejecuta el archivo malicioso. |
| 09:35 | Primeras conexiones salientes desde WS-ADM-07 hacia 203.0.113.45 (puerto 443) y el dominio cdn-update-delta.example. |
| 10:50 | El antivirus genera una alerta heurística de tipo «descargador» en WS-ADM-07. |
| 11:20 | Intentos de acceso desde WS-ADM-07 a la carpeta compartida \\\\SRV-FICHEROS\\Clientes. |
| 11:40 | Informática escala el caso al equipo de ciberseguridad. Se abre el incidente INC-2026-001. |

> **Nota sobre los indicadores del caso**
>
> Las direcciones IP (rango de documentación 203.0.113.0/24 y 198.51.100.0/24) y los dominios (.example) son **ficticios**, para no atacar ni consultar infraestructura real. Las pruebas prácticas reproducen el comportamiento en un laboratorio controlado y las consultas OSINT las hice sobre un indicador público real (apartado 2.5), sin conectarme a él.

## Entorno de laboratorio y condiciones éticas

Realicé todas las pruebas de forma individual, en máquinas virtuales propias, sin tocar equipos ni redes ajenos, tal como exige el enunciado. No usé malware real: utilicé el fichero de prueba EICAR y tráfico simulado.

| **Nombre** | **Descripción** | **Uso en el trabajo** |
|---|---|---|
| VM-WIN | Windows Server 2022 Datacenter (versión de evaluación) con Active Directory, en máquina virtual. Equipo SRV-DC01, dominio EMPRESA. IP 192.168.68.102. Microsoft Defender activo. | Representa el equipo de la víctima (WS-ADM-07 en el caso) y el servidor de dominio. |
| VM-KALI | Kali Linux en máquina virtual (equipo kali, usuario adrian). Misma red del laboratorio. IP 192.168.68.107. | Estación del analista y, a la vez, servidor que simula la IP del atacante (203.0.113.45). |
| ANFITRIÓN | Mi ordenador real, solo para navegar por webs públicas (OSINT, organismos CERT, AEPD). | Consultas OSINT y capturas de páginas web oficiales. |

> **Condiciones de las pruebas**
>
> Las pruebas se hicieron dentro de las máquinas virtuales. Las IP reales del laboratorio son 192.168.68.107 (VM-KALI) y 192.168.68.102 (VM-WIN), que sustituyen a las 192.168.56.x previstas inicialmente. En las capturas dejé visibles la hora y el nombre de la máquina (reloj de Windows y date; hostname en Linux). No existía una instantánea previa de VM-WIN, por lo que la recuperación (apartado 4.2) se documenta como verificación posterior a la eliminación.
