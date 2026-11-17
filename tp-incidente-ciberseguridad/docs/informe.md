# Gestión de un incidente de ciberseguridad

> Trabajo práctico individual. Caso ficticio: **Soluciones Delta, S.L.** (~100 empleados). Rol: responsable del equipo de ciberseguridad.

> Esta versión en Markdown es idéntica al informe en Word/PDF (carpeta [`docs/`](.)). Las capturas se enlazan desde [`../evidence/`](../evidence).


---

# Introducción, alcance y entorno de pruebas


## Resumen ejecutivo del caso

**Soluciones Delta, S.L.** (empresa ficticia creada para este trabajo; unos 100 empleados, servicios de gestión administrativa para clientes) ha sufrido un incidente de ciberseguridad. Varios empleados recibieron un correo que aparentaba proceder de Recursos Humanos. Uno de ellos abrió el documento adjunto y ejecutó un archivo malicioso. Después, el departamento de informática detectó conexiones salientes hacia IP externas, alertas del antivirus e intentos de acceso a carpetas compartidas. Se sospecha que se han podido extraer datos personales de clientes. La empresa no dispone de procedimientos formales de prevención ni de respuesta a incidentes.

En este documento actúo como **responsable del equipo de ciberseguridad**. El trabajo recorre el ciclo completo de gestión del incidente: prevención, detección, investigación, respuesta y recuperación, notificación y simulación de una reunión del equipo de respuesta. Sigue como referencia metodológica el ciclo de NIST SP 800-61 (preparación; detección y análisis; contención, erradicación y recuperación; actividad posterior al incidente) y la norma ISO/IEC 27035.


## Cronología supuesta del incidente (datos ficticios)

| Hora (16/11/2026) | Evento |
|---|---|
| 09:12 | 14 empleados reciben el correo «Actualización de nómina - acción requerida», remitente aparente: Recursos Humanos. |
| 09:31 | Un empleado de Administración (equipo WS-ADM-07) abre el adjunto *Nomina_Noviembre_2026.docm* y habilita las macros. Se ejecuta el archivo malicioso. |
| 09:35 | Primeras conexiones salientes desde WS-ADM-07 hacia 203.0.113.45 (puerto 443) y el dominio cdn-update-delta.example. |
| 10:50 | El antivirus genera una alerta heurística de tipo «descargador» en WS-ADM-07. |
| 11:20 | Intentos de acceso desde WS-ADM-07 a la carpeta compartida \\\\SRV-FICHEROS\\Clientes. |
| 11:40 | Informática escala el caso al equipo de ciberseguridad. Se abre el incidente INC-2026-001. |

> [!NOTE]
> **Nota sobre los indicadores del caso**
> Las direcciones IP (rango de documentación 203.0.113.0/24 y 198.51.100.0/24) y los dominios (.example) son **ficticios**, para no atacar ni consultar infraestructura real. Las pruebas prácticas reproducen el comportamiento en un laboratorio controlado y las consultas OSINT de la técnica se hacen sobre indicadores públicos reales.


## Entorno de laboratorio y condiciones éticas

Todas las pruebas se han realizado de forma individual, en máquinas virtuales propias y aisladas, sin tocar equipos ni redes ajenos, tal como exige el enunciado. No se ha utilizado malware real: se usan el fichero de prueba EICAR, un documento con una macro inofensiva y tráfico simulado.

| Nombre | Descripción | Uso en el trabajo |
|---|---|---|
| VM-WIN | Windows 10/11 en máquina virtual. Red «solo anfitrión» (host-only), IP 192.168.56.20. Microsoft Defender activo, Sysmon instalado. Instantánea «Estado limpio» creada antes de empezar. | Representa el equipo de la víctima (WS-ADM-07). |
| VM-KALI | Kali Linux (o Ubuntu) en máquina virtual. Misma red host-only, IP 192.168.56.10. | Estación del analista y, a la vez, servidor que simula la IP del atacante (203.0.113.45). |
| ANFITRIÓN | Tu ordenador real, solo para navegar por webs públicas (OSINT, organismos CERT, AEPD). | Consultas OSINT y capturas de páginas web oficiales. |

> [!WARNING]
> **Antes de empezar (importante)**
> 1) Crea una instantánea (snapshot) de VM-WIN y de VM-KALI. 2) Si tu antivirus del anfitrión salta con EICAR, es normal: trabaja siempre dentro de las máquinas virtuales. 3) Anota las IP reales de tus máquinas (comandos `ip a` y `ipconfig`) y sustituye en los comandos las IP de este documento si son distintas. 4) Haz las capturas con la hora y el nombre de la máquina visibles (en Windows, el reloj de la barra de tareas; en Linux, ejecuta `date; hostname` en la propia captura).


---

# 1. Prevención y concienciación


## 1.1 Principales riesgos y amenazas

El incidente es un ejemplo clásico de ingeniería social seguida de ejecución de malware. El análisis de riesgos de una empresa de este tamaño, sin procedimientos formales, arroja las siguientes amenazas prioritarias. Probabilidad (P) e Impacto (I) se valoran de 1 a 5.

| Amenaza / riesgo | P | I | Descripción y vínculo con el caso | Control principal |
|---|---|---|---|---|
| Phishing y spear-phishing | 5 | 4 | Correos que suplantan a RR. HH. Es el vector de entrada del incidente. | Filtrado de correo, SPF/DKIM/DMARC, formación |
| Malware (troyanos, ransomware, stealers) | 4 | 5 | Macro o ejecutable malicioso que descarga una segunda fase. | EDR/antivirus, macros bloqueadas, mínimo privilegio |
| Robo de credenciales | 4 | 5 | El atacante reutiliza credenciales para acceder a carpetas compartidas. | MFA, gestor de contraseñas, políticas de clave |
| Fuga de datos personales | 3 | 5 | Exfiltración de datos de clientes: sanciones RGPD y daño reputacional. | Cifrado, DLP, segmentación, control de accesos |
| Software sin actualizar | 4 | 4 | Vulnerabilidades conocidas aprovechables tras la ejecución inicial. | Gestión de parches |
| Permisos excesivos | 4 | 4 | Un usuario normal que puede ver carpetas de clientes amplía el daño. | Mínimo privilegio, revisión periódica de accesos |
| Ausencia de copias de seguridad fiables | 3 | 5 | Sin backups aislados, un ransomware paralizaría la empresa. | Regla 3-2-1, copias inmutables, pruebas de restauración |
| Amenaza interna (error o mala fe) | 3 | 4 | Empleado que reenvía datos o hace clic sin pensar. | Concienciación, registros, separación de funciones |
| Teletrabajo y dispositivos personales | 3 | 3 | Equipos fuera del perímetro, redes domésticas. | VPN, MDM, cifrado de disco |
| Falta de procedimiento de respuesta | 5 | 4 | Sin plan, la respuesta es lenta y desordenada (es el caso actual). | Plan de respuesta a incidentes (este trabajo) |


## 1.2 Normas de seguridad para los puestos de trabajo

Propuesta de normativa interna (política de uso aceptable), de obligado cumplimiento para toda la plantilla:

1. **Contraseñas:** mínimo 12 caracteres, únicas para cada servicio, gestionadas con un gestor de contraseñas corporativo. Prohibido compartirlas o anotarlas.
2. **Doble factor (MFA)** obligatorio en correo, VPN, aplicaciones de clientes y cuentas con privilegios.
3. **Bloqueo de pantalla** (Windows+L) siempre que se abandone el puesto; bloqueo automático a los 5 minutos.
4. **Correo electrónico:** no abrir adjuntos ni enlaces inesperados; las macros de Office permanecen **deshabilitadas**. Ante la duda, usar el botón «Reportar phishing» o escribir a seguridad.
5. **Software:** solo se instala software autorizado por TI. Los usuarios no tienen permisos de administrador local.
6. **Actualizaciones:** sistema operativo, navegador y ofimática se actualizan automáticamente. No se pospone un reinicio de parches más de 48 horas.
7. **Antivirus/EDR** activo y no desactivable por el usuario. Toda alerta se comunica a TI.
8. **Datos de clientes:** solo en las ubicaciones corporativas autorizadas. Prohibido copiarlos a USB, correo personal o servicios en la nube no autorizados.
9. **Cifrado:** discos de portátiles cifrados (BitLocker) y soportes extraíbles cifrados.
10. **Mesa limpia:** sin documentos con datos personales a la vista; destrucción segura de papel.
11. **Teletrabajo:** conexión por VPN corporativa y redes WiFi domésticas con WPA2/WPA3 y clave robusta.
12. **Notificación:** cualquier incidente o sospecha se comunica de inmediato a seguridad@solucionesdelta.example (ext. 1234). Comunicar a tiempo nunca será sancionado.


## 1.3 Plan de formación y concienciación

Un solo curso al año no cambia hábitos. El plan combina formación inicial, refuerzos breves y simulacros medibles durante 12 meses. Los simulacros de phishing se realizarían con herramientas como GoPhish, siempre con autorización de la dirección y sin sancionar a quien falle.

| Acción | Público | Duración / formato | Frecuencia |
|---|---|---|---|
| Sesión inicial «Seguridad básica»: phishing, contraseñas, MFA, datos personales | Toda la plantilla | 60 min, presencial/online | Al incorporarse y 1 vez al año |
| Microlecciones (vídeos de 3-5 min, tips por correo) | Toda la plantilla | 3-5 min | Mensual |
| Simulacro de phishing con informe individual y formación inmediata | Toda la plantilla | Campaña de 1-2 semanas | Trimestral |
| Formación específica RGPD y tratamiento de datos de clientes | Administración, atención al cliente, comerciales | 90 min | Anual |
| Formación técnica: logs, respuesta a incidentes, forense básico | Equipo TI y seguridad | 8 h taller | Semestral |
| Taller para dirección y ejercicio de mesa (como la simulación del apartado 6) | Dirección, DPO, legal, comunicación | 2 h | Anual |
| Cartel de phishing y guía de buenas prácticas (apartado 1.4) | Toda la plantilla | Impreso y en intranet | Permanente, renovado cada año |

**Indicadores para medir la eficacia:** porcentaje de empleados que hacen clic en el simulacro (objetivo: bajar del 25 % al 5 %), porcentaje que reporta el correo (objetivo: superar el 60 %), tiempo medio entre recepción y reporte, nº de incidentes por error humano y resultado de un test de conocimientos antes y después.


## 1.4 Cartel sobre phishing y guía de buenas prácticas

El cartel (siguiente página) está pensado para imprimirse en A4/A3 y colocarse en zonas comunes y pantallas de la intranet.

> ### ¿ES REAL ESTE CORREO?
> El phishing entra por tu bandeja de entrada. **Tú eres nuestro mejor cortafuegos.**
>
> **7 señales de alarma:** 1) Urgencia o amenaza · 2) Remitente raro · 3) Adjunto inesperado (.docm, .xlsm, .zip, .exe, .iso) · 4) Enlaces sospechosos · 5) Piden datos o claves · 6) Faltas y tono extraño · 7) Demasiado bueno para ser verdad.
>
> **Regla de oro:** si dudas, no abras, no hagas clic y no respondas. Pregunta por otro canal.
>
> **Si has caído:** 1) Desconecta (sin apagar) · 2) Avisa ya a TI (ext. 1234) · 3) No borres nada.
>
> *(El cartel completo, con su diseño, está en las versiones Word y PDF de esta carpeta.)*


### Guía de buenas prácticas frente al phishing (una página)

| Antes de hacer clic | Si dudas | Si ya has hecho clic |
|---|---|---|
| • Comprueba la dirección real del remitente, no solo el nombre.<br>• Desconfía de la urgencia y de lo inesperado.<br>• Pasa el ratón sobre los enlaces y revisa el dominio.<br>• No habilites macros ni «contenido» en documentos recibidos por correo.<br>• Comprueba la extensión del adjunto (.docm, .xlsm, .exe, .iso, .zip protegidos con clave).<br>• Recuerda: RR. HH. no pide credenciales por correo. | • No respondas, no reenvíes y no abras el adjunto.<br>• Contacta con la persona o el departamento por otro canal.<br>• Pulsa «Reportar phishing» o reenvía el correo **como adjunto** a seguridad.<br>• Mantén el correo hasta que TI confirme.<br>• Escribe la URL a mano en el navegador en vez de usar el enlace.<br>• Usa MFA siempre: aunque roben la clave, no entrarán. | • Desconecta el equipo de la red (cable o WiFi), sin apagarlo.<br>• Avisa a TI inmediatamente.<br>• Si introdujiste una contraseña, cámbiala desde otro equipo seguro.<br>• No borres correos ni archivos.<br>• Anota hora, qué abriste y qué ocurrió.<br>• Colabora con TI; no se trata de buscar culpables. |


### Buenas prácticas generales

- Usa un gestor de contraseñas y activa MFA en todas las cuentas importantes.
- Mantén todo actualizado y no desactives el antivirus.
- Evita redes WiFi públicas sin VPN y no mezcles datos personales y corporativos.
- Haz copias de seguridad y comprueba de vez en cuando que se pueden restaurar.
- Comparte la información justa y solo con quien la necesita (principio de mínimo privilegio).


## 1.5 Criptografía aplicada a la seguridad de la empresa

La criptografía es la base técnica de varias medidas del plan. A continuación se explica cada concepto, su utilidad en la empresa y, cuando procede, una prueba práctica en VM-KALI. Antes, prepara una carpeta de trabajo:

```text
mkdir ~/cripto && cd ~/cripto
echo "Datos confidenciales del cliente 0001" > secreto.txt
```


### Cifrado simétrico

Se usa **la misma clave** para cifrar y descifrar (AES, ChaCha20). Es muy rápido, ideal para grandes volúmenes: discos de portátiles (BitLocker), copias de seguridad, bases de datos y túneles VPN. Su problema es la distribución segura de la clave: quien la tenga puede descifrar. En el caso, si los portátiles y el servidor de ficheros estuvieran cifrados y los datos de clientes protegidos, el impacto de una exfiltración sería menor.

```text
openssl enc -aes-256-cbc -pbkdf2 -salt -in secreto.txt -out secreto.enc
cat secreto.enc                      # contenido ilegible
openssl enc -d -aes-256-cbc -pbkdf2 -in secreto.enc -out secreto_dec.txt
cat secreto_dec.txt
```

> **Captura 1.1** — Cifrado simétrico AES-256 con OpenSSL
>
> - **Qué capturar:** El proceso completo de cifrar secreto.txt, mostrar que secreto.enc es ilegible y descifrarlo recuperando el texto original.
> - **Máquina / entorno:** VM-KALI, terminal, en ~/cripto.
> - **Herramienta / comando:** `openssl enc -aes-256-cbc -pbkdf2 -salt -in secreto.txt -out secreto.enc` y después `openssl enc -d ...`
> - **Debe verse:** Los comandos, la petición de contraseña, el contenido ilegible de secreto.enc y el texto recuperado. Añade `date; hostname` al final.
>
> ![Figura 1.1. Cifrado simétrico AES-256 con OpenSSL](../evidence/1.1.png)


### Cifrado asimétrico

Cada usuario tiene un **par de claves**: la pública (se reparte) y la privada (se guarda en secreto). Lo cifrado con la pública solo lo descifra la privada. Resuelve el problema de la distribución de claves y permite enviar datos confidenciales a alguien sin haber compartido un secreto antes. Es más lento, así que en la práctica se usa para intercambiar una clave simétrica (cifrado híbrido), como hace TLS. Algoritmos: RSA, ECC.

```text
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out priv.pem
openssl pkey -in priv.pem -pubout -out pub.pem
openssl pkeyutl -encrypt -pubin -inkey pub.pem -in secreto.txt -out secreto.rsa
openssl pkeyutl -decrypt -inkey priv.pem -in secreto.rsa
```

> **Captura 1.2** — Par de claves RSA y cifrado asimétrico
>
> - **Qué capturar:** Generación del par de claves, cifrado con la clave pública y descifrado con la privada.
> - **Máquina / entorno:** VM-KALI, terminal, en ~/cripto.
> - **Herramienta / comando:** `openssl genpkey ...`, `openssl pkey ... -pubout`, `openssl pkeyutl -encrypt ...`, `openssl pkeyutl -decrypt ...`
> - **Debe verse:** Los cuatro comandos y el texto original recuperado al final. Puedes añadir `ls -l` para ver priv.pem, pub.pem y secreto.rsa.
>
> ![Figura 1.2. Par de claves RSA y cifrado asimétrico](../evidence/1.2.png)


### Funciones hash

Una función hash (SHA-256, SHA-3) transforma cualquier dato en una huella de longitud fija. Es **unidireccional** (no se puede invertir) y cualquier cambio mínimo en el dato altera por completo la huella (efecto avalancha). Utilidad: comprobar la integridad de ficheros y evidencias, identificar malware por su hash, almacenar contraseñas (con sal y algoritmos lentos como bcrypt/Argon2) y servir de base a las firmas digitales. La práctica con SHA-256 se desarrolla en el apartado 3.6.


### Firma electrónica

La firma electrónica garantiza **autenticidad** (quién firma), **integridad** (no se ha modificado) y **no repudio**. Se calcula el hash del documento y se cifra con la clave **privada** del firmante; cualquiera puede verificarlo con la clave pública. En la empresa sirve para firmar contratos, facturas, informes de incidentes y actas de custodia, o correos (S/MIME). Es la base del DNI electrónico y del certificado de empresa.

```text
openssl dgst -sha256 -sign priv.pem -out firma.bin secreto.txt
openssl dgst -sha256 -verify pub.pem -signature firma.bin secreto.txt   # Verified OK
echo "x" >> secreto.txt
openssl dgst -sha256 -verify pub.pem -signature firma.bin secreto.txt   # Verification failure
```

> **Captura 1.3** — Firma digital: verificación correcta y verificación fallida tras modificar el archivo
>
> - **Qué capturar:** La firma de secreto.txt, la verificación correcta («Verified OK») y la verificación fallida tras añadir una línea al archivo («Verification failure»).
> - **Máquina / entorno:** VM-KALI, terminal, en ~/cripto.
> - **Herramienta / comando:** `openssl dgst -sha256 -sign priv.pem ...` y `openssl dgst -sha256 -verify pub.pem ...` (dos veces).
> - **Debe verse:** Ambos resultados en la misma captura, para demostrar que la firma detecta la manipulación.
>
> ![Figura 1.3. Firma digital: verificación correcta y verificación fallida tras modificar el archivo](../evidence/1.3.png)


### Certificados digitales y PKI

Un **certificado digital** (X.509) vincula una clave pública con una identidad (persona, servidor o empresa) y está firmado por una **autoridad de certificación (CA)** de confianza. Una **PKI** (Public Key Infrastructure) es el conjunto de elementos que emite, distribuye, valida y revoca certificados: CA raíz y CA subordinadas, autoridad de registro (verifica la identidad), repositorio, listas de revocación (CRL) y OCSP. Cuando el navegador muestra el candado, valida la cadena servidor, CA intermedia y CA raíz, además de las fechas y la revocación. Utilidad en la empresa: HTTPS en servicios internos, VPN, autenticación de equipos y usuarios, correo firmado y cifrado, firma de documentos con el certificado de la FNMT. Ojo: un certificado válido no garantiza que un sitio sea legítimo: muchas webs de phishing también tienen HTTPS.

> **Captura 1.4** — Cadena de certificación de un sitio web
>
> - **Qué capturar:** El certificado de un sitio web oficial (por ejemplo www.incibe.es o www.aepd.es) con su ruta de certificación (certificado del servidor, CA intermedia y CA raíz) y las fechas de validez.
> - **Máquina / entorno:** ANFITRIÓN, navegador (Chrome/Edge/Firefox).
> - **Herramienta / comando:** Clic en el candado junto a la URL, «La conexión es segura», «El certificado es válido» y pestaña «Ruta de certificación» / «Detalles». Alternativa en VM-KALI: `openssl s_client -connect www.incibe.es:443 -showcerts </dev/null | openssl x509 -noout -subject -issuer -dates`
> - **Debe verse:** Emitido para, emitido por, fechas de validez y la jerarquía de certificación.
>
> ![Figura 1.4. Cadena de certificación de un sitio web](../evidence/1.4.png)


### Diffie-Hellman

Diffie-Hellman (DH) permite que **dos partes acuerden una clave secreta compartida a través de un canal inseguro** sin enviarla nunca. Cada parte elige un secreto privado; intercambian valores públicos derivados mediante exponenciación modular y ambas calculan el mismo secreto, imposible de deducir para un espía por el problema del logaritmo discreto. Utilidad: es la base del intercambio de claves de TLS (ECDHE), VPN (IPsec/WireGuard) y SSH, y proporciona *secreto perfecto hacia adelante* (PFS): si más tarde roban la clave del servidor, no se pueden descifrar sesiones pasadas.

Ejemplo con números pequeños (solo didáctico): p = 23, g = 5. Alicia elige a = 6 y envía A = 5<sup>6</sup> mod 23 = 8. Beto elige b = 15 y envía B = 5<sup>15</sup> mod 23 = 19. Alicia calcula 19<sup>6</sup> mod 23 = 2 y Beto 8<sup>15</sup> mod 23 = 2. La clave compartida es **2**.

```text
python3 -c "p=23;g=5;a=6;b=15;A=pow(g,a,p);B=pow(g,b,p);print('A=',A,'B=',B,'secreto Alicia=',pow(B,a,p),'secreto Beto=',pow(A,b,p))"
```

> **Captura 1.5** — Intercambio de claves Diffie-Hellman con números pequeños
>
> - **Qué capturar:** La salida del comando de Python con A, B y los dos secretos compartidos iguales (valor 2).
> - **Máquina / entorno:** VM-KALI, terminal.
> - **Herramienta / comando:** El comando `python3 -c "p=23;g=5;a=6;b=15;..."` de arriba.
> - **Debe verse:** A = 8, B = 19, secreto de Alicia = 2 y secreto de Beto = 2.
>
> ![Figura 1.5. Intercambio de claves Diffie-Hellman con números pequeños](../evidence/1.5.png)


### Resumen

| Concepto | Qué garantiza | Uso en Soluciones Delta |
|---|---|---|
| Cifrado simétrico (AES) | Confidencialidad, rápido | Cifrado de discos, copias de seguridad, datos de clientes |
| Cifrado asimétrico (RSA/ECC) | Confidencialidad sin compartir secreto previo | Intercambio de claves, correo cifrado (S/MIME, PGP) |
| Hash (SHA-256) | Integridad | Evidencias, verificación de descargas, identificación de malware |
| Firma electrónica | Autenticidad, integridad, no repudio | Contratos, facturas, informes y actas firmadas |
| Certificado digital | Vincula clave pública e identidad | HTTPS, VPN, autenticación, firma |
| PKI | Confianza y gestión del ciclo de vida de certificados | Emisión y revocación de certificados corporativos |
| Diffie-Hellman | Acuerdo de clave y PFS | Base de TLS, VPN y SSH |


---

# 2. Detección y auditoría


## 2.1 Clasificación y gravedad del incidente

Siguiendo la taxonomía de la Guía Nacional de Notificación y Gestión de Ciberincidentes y los criterios de NIST SP 800-61:

| Criterio | Valoración | Justificación |
|---|---|---|
| Tipo de incidente | Código dañino (malware) con origen en phishing; posible compromiso de la información (exfiltración) | Correo fraudulento con adjunto malicioso ejecutado por un empleado; conexiones salientes anómalas. |
| Vector de ataque | Correo electrónico (adjunto con macro) | MITRE ATT&CK T1566.001 (Spearphishing Attachment) y T1204.002 (User Execution: Malicious File). |
| Peligrosidad | MUY ALTA | El código se ejecutó, hay comunicación con infraestructura externa (posible C2) y movimiento hacia recursos compartidos. |
| Impacto | ALTO (puede pasar a CRÍTICO) | Posible fuga de datos personales de clientes; afecta a confidencialidad. Sube a crítico si se confirma la extracción. |
| Prioridad | P1 - Atención inmediata | Obligaciones legales (RGPD), riesgo reputacional y atacante potencialmente activo. |
| Estado | Abierto, en contención | INC-2026-001. Se revisará la clasificación a medida que haya evidencias. |

**Gravedad global provisional: ALTA / CRÍTICA**. Se adopta el principio de precaución: hasta que se demuestre lo contrario, se asume que hay exfiltración y que el atacante mantiene acceso.


## 2.2 Sistemas y servicios potencialmente afectados

| Sistema / servicio | Motivo de sospecha | Prioridad de revisión |
|---|---|---|
| WS-ADM-07 (equipo del empleado) | Origen de la ejecución y de las conexiones externas | Inmediata |
| Cuenta de usuario del empleado | Credenciales y tokens en memoria o navegador pueden haberse robado | Inmediata |
| Servidor de ficheros SRV-FICHEROS (carpeta Clientes) | Intentos de acceso detectados | Inmediata |
| Servidor de correo / pasarela antispam | Otros 13 destinatarios del correo; posible reenvío interno | Alta |
| Los otros 13 equipos y usuarios que recibieron el correo | Pueden haber abierto el adjunto sin avisar | Alta |
| Controlador de dominio / Active Directory | Posible enumeración, abuso de cuentas privilegiadas | Alta |
| Base de datos / CRM de clientes | Almacén de datos personales objetivo del atacante | Alta |
| Firewall, proxy y DNS | Origen de los registros de conexiones salientes | Media (fuente de evidencia) |
| Copias de seguridad | Si son accesibles desde la red, podrían verse comprometidas | Media |
| VPN, aplicaciones en la nube y correo de la nube | Posible reutilización de credenciales robadas | Media |


## 2.3 Herramientas de detección y monitorización

| Categoría | Herramientas | Para qué se usan en este incidente |
|---|---|---|
| Antivirus / EDR | Microsoft Defender for Endpoint, CrowdStrike, SentinelOne; en laboratorio, Microsoft Defender | Alertas, aislamiento remoto del equipo, árbol de procesos, búsqueda de IOC en toda la flota. |
| SIEM / análisis de logs | Wazuh, Elastic Security, Splunk, Microsoft Sentinel | Centralizar logs y correlacionar: correo, endpoint, firewall y AD. |
| Telemetría de sistema | Sysmon (Sysinternals) con configuración SwiftOnSecurity, Visor de eventos | Creación de procesos, conexiones de red, DNS, ficheros creados. |
| Red e IDS/IPS | Wireshark, tcpdump, Zeek, Suricata, Security Onion, NetFlow del firewall | Detectar beaconing, volúmenes anómalos y destinos raros. |
| Correo | Logs de la pasarela, MXToolbox, cabeceras | Cuántos correos, quién los abrió, quién hizo clic. |
| Hunting y recogida | Velociraptor, KAPE, Autoruns, Process Explorer, TCPView | Buscar persistencia y recolectar artefactos. |
| Inteligencia (OSINT/TI) | VirusTotal, AbuseIPDB, urlscan.io, Shodan, MISP, AlienVault OTX, whois | Reputación y contexto de IP, dominios y hashes. |


## 2.4 Registros que se consultarían


### Antivirus / EDR

Consola central de alertas: nombre de la detección, ruta del fichero, usuario, acción tomada (bloqueado, en cuarentena, permitido). En Windows, el registro *Microsoft-Windows-Windows Defender/Operational* con los eventos **1116** (malware detectado) y **1117** (acción realizada). Interesa saber si hubo ejecución antes de la alerta.


### Firewall y proxy

Conexiones salientes desde WS-ADM-07: destino, puerto, bytes enviados y recibidos, frecuencia. Busco conexiones periódicas (beaconing), destinos nunca antes vistos, puertos inusuales y subidas de datos grandes (indicador de exfiltración). Además, trazas de los DNS: consultas al dominio cdn-update-delta.example.


### Sistema operativo (Windows y servidor de ficheros)

| Registro / ID | Qué indica |
|---|---|
| Security 4624 / 4625 | Inicios de sesión correctos / fallidos; el tipo 3 indica acceso por red (movimiento lateral). |
| Security 4688 | Creación de procesos (con línea de comandos si está habilitado): WINWORD lanzando PowerShell o cmd es muy sospechoso. |
| Security 5140 / 5145 | Acceso a recursos compartidos de red (qué carpetas y qué usuario). |
| Security 4672 / 4768 / 4769 | Privilegios asignados y tickets Kerberos: abuso de cuentas privilegiadas. |
| Security 1102 / System 104 | Borrado de registros de auditoría (el atacante borra sus huellas). |
| System 7045 / Security 4698 | Instalación de servicios y creación de tareas programadas (persistencia). |
| Sysmon 1 / 3 / 11 / 22 | Proceso creado / conexión de red / fichero creado / consulta DNS. |
| PowerShell 4104 | Contenido de scripts ejecutados (Script Block Logging). |


### Tráfico de red

Captura y análisis con Wireshark/tcpdump o NetFlow: conversaciones (Statistics > Conversations), consultas DNS, campo SNI de TLS (`tls.handshake.extensions_server_name`), periodicidad de las conexiones y volumen enviado. Filtros útiles: `ip.addr == 203.0.113.45`, `dns`, `http.request`.


### Práctica de laboratorio A: simular la comunicación sospechosa

Para tener registros reales que analizar, se simula en el laboratorio un malware que contacta de forma periódica con un servidor externo (*beaconing*). VM-KALI hace de servidor del atacante (en el caso, 203.0.113.45) y VM-WIN de equipo infectado.

**En VM-KALI** (servidor web de pruebas y captura de tráfico; ajusta el nombre de la interfaz con `ip a`):

```text
mkdir ~/servidor && cd ~/servidor
sudo tcpdump -i eth0 host 192.168.56.20 -w ~/beacon.pcap &     # captura en segundo plano
python3 -m http.server 8000
```

**En VM-WIN**, PowerShell como administrador (activa antes el registro del firewall):

```text
netsh advfirewall set currentprofile logging allowedconnections enable
netsh advfirewall set currentprofile logging droppedconnections enable
netsh advfirewall set currentprofile logging maxfilesize 16384

# Simulación de beaconing: una petición cada 10 segundos (dejar en marcha ~2 minutos)
while ($true) { try { Invoke-WebRequest -Uri "http://192.168.56.10:8000/beacon" -UseBasicParsing | Out-Null } catch {}; Start-Sleep -Seconds 10 }
```

> [!NOTE]
> **Qué estás simulando**
> Esto no es malware: son peticiones HTTP inocuas a tu propia máquina Kali. Sirve para generar el mismo patrón que un implante real (conexión saliente periódica a una IP externa) y poder detectarlo con las herramientas del apartado.


### Práctica B: detección por antivirus con el fichero de prueba EICAR

EICAR es una cadena estándar inofensiva que todos los antivirus detectan como si fuera malware. En VM-WIN, PowerShell:

```text
Set-Content -Path $env:USERPROFILE\Desktop\eicar.txt -Value 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
```

Defender lo detectará y lo pondrá en cuarentena casi de inmediato. Si no ocurre, abre el fichero o ejecuta un análisis rápido.

> **Captura 2.1** — Detección del antivirus: historial de protección
>
> - **Qué capturar:** La detección de EICAR en «Seguridad de Windows > Protección antivirus y contra amenazas > Historial de protección», con el nombre de la amenaza, la fecha y la acción realizada.
> - **Máquina / entorno:** VM-WIN.
> - **Herramienta / comando:** Seguridad de Windows > Historial de protección (Defender).
> - **Debe verse:** Nombre de la amenaza (Virus:DOS/EICAR_Test_File), ruta del fichero, hora y estado (en cuarentena).
>
> ![Figura 2.1. Detección del antivirus: historial de protección](../evidence/2.1.png)

> **Captura 2.2** — Evento de Defender en el Visor de eventos (ID 1116/1117)
>
> - **Qué capturar:** El evento de detección y de acción de Defender en el registro operativo.
> - **Máquina / entorno:** VM-WIN.
> - **Herramienta / comando:** Visor de eventos > Registros de aplicaciones y servicios > Microsoft > Windows > Windows Defender > Operational; filtrar por ID 1116 y 1117.
> - **Debe verse:** ID de evento, descripción (nombre, ruta, usuario) y la hora. Se debe ver el panel de detalles inferior.
>
> ![Figura 2.2. Evento de Defender en el Visor de eventos (ID 1116/1117)](../evidence/2.2.png)

> **Captura 2.3** — Registro del firewall de Windows (pfirewall.log)
>
> - **Qué capturar:** Las líneas del log del firewall que muestran las conexiones periódicas desde 192.168.56.20 a 192.168.56.10 puerto 8000.
> - **Máquina / entorno:** VM-WIN, PowerShell como administrador, con el beaconing en marcha.
> - **Herramienta / comando:** `Get-Content C:\Windows\System32\LogFiles\Firewall\pfirewall.log -Tail 25`
> - **Debe verse:** Líneas con ALLOW, TCP, origen 192.168.56.20, destino 192.168.56.10 y puerto 8000, a intervalos de unos 10 s.
>
> ![Figura 2.3. Registro del firewall de Windows (pfirewall.log)](../evidence/2.3.png)

> **Captura 2.4** — Registros del sistema operativo: inicios de sesión (4624/4625)
>
> - **Qué capturar:** Eventos de seguridad de inicio de sesión. Provoca antes 2 o 3 intentos fallidos desde la pantalla de bloqueo o con `runas /user:usuarioinexistente cmd` para generar eventos 4625.
> - **Máquina / entorno:** VM-WIN.
> - **Herramienta / comando:** Visor de eventos > Registros de Windows > Seguridad; filtrar por 4625 (y 4624). O con PowerShell: `Get-WinEvent -FilterHashtable @{LogName="Security";Id=4625} -MaxEvents 5`
> - **Debe verse:** El ID, la cuenta, el tipo de inicio de sesión y la hora.
>
> ![Figura 2.4. Registros del sistema operativo: inicios de sesión (4624/4625)](../evidence/2.4.png)

> **Captura 2.5** — Tráfico de red: peticiones periódicas en el servidor y en Wireshark
>
> - **Qué capturar:** Dos cosas en una sola imagen o en dos: (a) el terminal de VM-KALI con las peticiones GET /beacon cada ~10 segundos, (b) Wireshark con el filtro de tráfico de 192.168.56.20.
> - **Máquina / entorno:** VM-KALI (terminal del python3 http.server y Wireshark abierto en eth0).
> - **Herramienta / comando:** Wireshark con filtro de visualización `ip.addr == 192.168.56.20 && http.request`.
> - **Debe verse:** Columna de tiempo con las peticiones separadas por ~10 s, IP origen/destino y la petición GET /beacon.
>
> ![Figura 2.5. Tráfico de red: peticiones periódicas en el servidor y en Wireshark](../evidence/2.5.png)


## 2.5 Investigación OSINT de IP y dominios sospechosos

OSINT (inteligencia de fuentes abiertas) permite entender el origen y la reputación de un indicador sin tocar la infraestructura del atacante. **Regla: consultar, nunca conectarse** a la IP o el dominio sospechosos desde la red de la empresa.

| Indicador (caso) | Fuentes y técnicas | Qué se busca |
|---|---|---|
| IP 203.0.113.45 | VirusTotal, AbuseIPDB, Shodan/Censys, ipinfo.io, whois (RIR), AlienVault OTX | País, proveedor (ASN), reputación, informes de abuso, puertos y servicios expuestos, relación con otros dominios. |
| Dominio cdn-update-delta.example | whois, dig/nslookup, VirusTotal, urlscan.io, crt.sh (certificados), SecurityTrails | Fecha de registro (dominios recién creados son sospechosos), registrante, servidores DNS, IP asociadas, certificados emitidos. |
| Dominio rrhh-solucionesdelta.example (typosquatting) | whois, MXToolbox (SPF/DMARC), comparación con el dominio legítimo | Parecido visual con el nombre de la empresa, antigüedad, configuración de correo. |
| Hash del adjunto | VirusTotal, MalwareBazaar, Hybrid Analysis | Si el fichero es conocido y qué familia de malware es. |

> [!WARNING]
> **Cómo hacer la parte práctica con datos reales**
> Las IP y dominios del caso son ficticios y no devolverán información útil. Para demostrar la técnica, elige **un indicador real ya publicado** como malicioso (por ejemplo, uno de la lista pública de Feodo Tracker o URLhaus de abuse.ch) y consúltalo **solo en las webs de OSINT**, sin abrirlo ni conectarte a él. En el informe indica: «indicador de ejemplo real utilizado para demostrar la técnica, equivalente a 203.0.113.45 del caso».

> **Captura 2.6** — Consulta de reputación de IP en VirusTotal
>
> - **Qué capturar:** La ficha de un indicador (IP o dominio) real y malicioso en VirusTotal: detecciones, país, ASN y relaciones.
> - **Máquina / entorno:** ANFITRIÓN, navegador.
> - **Herramienta / comando:** virustotal.com > pestaña Search > pegar la IP o dominio.
> - **Debe verse:** El indicador consultado, el número de motores que lo marcan como malicioso, el país/ASN y la fecha del último análisis.
>
> ![Figura 2.6. Consulta de reputación de IP en VirusTotal](../evidence/2.6.png)

> **Captura 2.7** — Consulta de la misma IP en AbuseIPDB
>
> - **Qué capturar:** Informe de abuso de la misma IP: porcentaje de confianza de abuso, nº de reportes, categorías.
> - **Máquina / entorno:** ANFITRIÓN, navegador.
> - **Herramienta / comando:** abuseipdb.com > Check > IP.
> - **Debe verse:** La IP, el «Abuse Confidence Score», el proveedor (ISP), el país y las categorías de los reportes.
>
> ![Figura 2.7. Consulta de la misma IP en AbuseIPDB](../evidence/2.7.png)

> **Captura 2.8** — whois y dig/nslookup sobre un dominio
>
> - **Qué capturar:** Datos de registro (fechas de creación, registrador, servidores DNS) y resolución DNS de un dominio. Usa un dominio real malicioso conocido o, para práctica inocua, el dominio de tu centro.
> - **Máquina / entorno:** VM-KALI, terminal.
> - **Herramienta / comando:** `whois dominio.tld | head -40` y `dig dominio.tld ANY +noall +answer` (o `nslookup dominio.tld`).
> - **Debe verse:** Fecha de creación del dominio, registrador, servidores de nombres y la(s) IP a la(s) que resuelve.
>
> ![Figura 2.8. whois y dig/nslookup sobre un dominio](../evidence/2.8.png)


## 2.6 Ficha de registro del incidente

| Campo | Valor |
|---|---|
| ID de incidente | INC-2026-001 |
| Fecha y hora de detección | 16/11/2026, 10:50 (alerta de antivirus). Escalado a ciberseguridad a las 11:40. |
| Detectado por | Departamento de informática (alerta de antivirus y revisión de firewall) |
| Responsable del incidente | Responsable de ciberseguridad ([tu nombre]) |
| Tipo / categoría | Código dañino con origen en phishing; posible fuga de información |
| Gravedad / prioridad | Alta, potencialmente crítica / P1 |
| Estado | Abierto - en contención |
| Vector de entrada | Correo electrónico con adjunto Nomina_Noviembre_2026.docm (macro) |
| Activos afectados (confirmados) | WS-ADM-07; cuenta del usuario afectado |
| Activos en revisión | SRV-FICHEROS, 13 equipos receptores del correo, AD, CRM, correo, copias de seguridad |
| Datos potencialmente afectados | Datos personales de clientes (identificación, contacto y, posiblemente, facturación) |
| Indicadores de compromiso (IOC) | IP 203.0.113.45 y 198.51.100.23; dominios cdn-update-delta.example y rrhh-solucionesdelta.example; remitente rrhh.nominas@... ; SHA-256 del adjunto: [valor calculado en el apartado 3.6] |
| Técnicas ATT&CK | T1566.001, T1204.002, T1071 (protocolo de aplicación para C2), T1083 (descubrimiento de ficheros), T1021.002 (SMB), T1041 (exfiltración por canal C2, por confirmar) |
| Acciones realizadas | Apertura de incidente, preservación de logs, aislamiento de WS-ADM-07, bloqueo de IOC en firewall y DNS, aviso a dirección y al DPO |
| Notificaciones | Dirección y DPO (internas). AEPD: pendiente de valoración (plazo máximo 72 h desde el conocimiento). |
| Próximos pasos | Análisis forense, revisión de las carpetas accedidas, restablecimiento de credenciales, decisión sobre notificación y recuperación |
| Lecciones aprendidas | Se completa al cierre (apartado 4.3 y conclusiones) |


---

# 3. Investigación y análisis


## 3.1 Evidencias que es necesario recopilar

Se recopilan siguiendo el **orden de volatilidad** (RFC 3227), de más a menos volátil, porque lo que está en memoria desaparece al apagar el equipo:

| Orden | Evidencia | Fuente / método |
|---|---|---|
| 1 | Memoria RAM (procesos, conexiones, claves, malware residente) | Volcado con FTK Imager, WinPmem o DumpIt del equipo encendido |
| 2 | Estado de red y procesos en ejecución | netstat, Get-NetTCPConnection, tasklist, TCPView, tabla ARP/DNS cache |
| 3 | Sesiones y usuarios conectados | query user, net session, logs de AD |
| 4 | Disco del equipo afectado (imagen forense) | Imagen bit a bit con FTK Imager o dd, con bloqueo de escritura |
| 5 | Logs de sistema: Windows, Sysmon, PowerShell, Defender | Exportar .evtx |
| 6 | Logs de red: firewall, proxy, DNS, NetFlow, pcap | Exportar desde dispositivos y SIEM |
| 7 | Correo original y logs de la pasarela | Fichero .eml con cabeceras completas, trazas de entrega y clics |
| 8 | Archivo malicioso (adjunto y payload descargado) | Copia con hash, nunca ejecutar fuera del laboratorio |
| 9 | Logs del servidor de ficheros y AD | Eventos 5140/5145, 4624, 4768/4769 |
| 10 | Copias de seguridad y documentación | Estado de backups, inventario, políticas |


## 3.2 Preservación de la integridad de las evidencias

- **No trabajar sobre el original:** se hace una imagen forense y se analiza siempre la copia.
- **Bloqueo de escritura** (write-blocker hardware o software) al adquirir discos.
- **Hash SHA-256 antes y después** de cada copia; deben coincidir. Se registra en el acta.
- **Documentar todo:** quién, cuándo, cómo, con qué herramienta y versión, hora sincronizada (NTP) y zona horaria.
- **Almacenamiento seguro:** originales en bolsa o caja precintada y etiquetada; copias en un repositorio de solo lectura, con acceso restringido y cifrado.
- **No apagar** el equipo antes de volcar la memoria. Si hay que aislar, desconectar de la red; no reiniciar.
- **Registrar las acciones del analista:** cada comando ejecutado sobre un equipo vivo modifica el sistema; se anota.
- **Separar roles:** quien recoge la evidencia no es quien la analiza, cuando es posible.


## 3.3 Investigación del correo electrónico

Se solicita al usuario que **no borre** el correo y se reenvía a seguridad **como adjunto (.eml)** para conservar las cabeceras. Se analizan los siguientes elementos:

| Elemento | Qué comprobar | Hallazgo en el caso (correo de ejemplo del Anexo A) |
|---|---|---|
| From vs. Return-Path / Reply-To | Coincidencia entre dominios | From aparenta rrhh@solucionesdelta.example, pero Return-Path y Reply-To van a otros dominios. |
| Cadena Received (de abajo a arriba) | Primer servidor que entregó el mensaje, IP de origen | Origen en 203.0.113.45, ajeno a la infraestructura de la empresa. |
| Authentication-Results | SPF, DKIM, DMARC | spf=fail, dkim=none, dmarc=fail: suplantación del dominio. |
| Asunto, cuerpo, tono | Urgencia, saludo genérico, faltas | Asunto de urgencia y mensaje sin personalizar. |
| Adjunto | Extensión, nombre, hash | Documento .docm que pide habilitar macros. |
| Enlaces | URL reales frente al texto mostrado | Dominio rrhh-solucionesdelta.example (typosquatting). |

En la práctica se trabaja con el correo de ejemplo del **Anexo A** (un fichero .eml ficticio que debes crear tú mismo en VM-KALI). Nunca analices un adjunto real fuera de un entorno aislado.

> **Captura 3.1** — Análisis de cabeceras del correo con la línea de comandos
>
> - **Qué capturar:** Las cabeceras relevantes del correo de ejemplo phishing_sample.eml, extraídas con grep.
> - **Máquina / entorno:** VM-KALI, terminal, en la carpeta donde guardaste phishing_sample.eml (ver Anexo A).
> - **Herramienta / comando:** `grep -Ei '^(from|reply-to|return-path|received|authentication-results|subject|x-originating-ip):' phishing_sample.eml`
> - **Debe verse:** Todas las cabeceras con sus valores: se debe apreciar el desajuste entre From y Reply-To/Return-Path y los SPF/DKIM/DMARC en fallo.
>
> ![Figura 3.1. Análisis de cabeceras del correo con la línea de comandos](../evidence/3.1.png)

> **Captura 3.2** — Análisis de cabeceras con MXToolbox Email Header Analyzer
>
> - **Qué capturar:** El resultado del análisis de las cabeceras del mismo correo en una herramienta web.
> - **Máquina / entorno:** ANFITRIÓN, navegador (mxtoolbox.com/EmailHeaders.aspx).
> - **Herramienta / comando:** Pega el contenido de las cabeceras de phishing_sample.eml (sin el cuerpo con datos sensibles reales) y pulsa Analyze Headers.
> - **Debe verse:** La tabla de resultados con los saltos (Received) y el bloque de SPF/DKIM/DMARC.
>
> ![Figura 3.2. Análisis de cabeceras con MXToolbox Email Header Analyzer](../evidence/3.2.png)


## 3.4 Investigación del archivo malicioso

El análisis se hace en dos fases, siempre en el entorno aislado: **análisis estático** (sin ejecutar el fichero) y, si hace falta, **análisis dinámico** en un sandbox (Any.Run, Hybrid Analysis, Cuckoo) con la red controlada. Para un documento ofimático con macros, el procedimiento estático es:

1. Identificar el tipo real del fichero (`file`), no fiarse de la extensión.
2. Calcular el hash SHA-256 y consultarlo en VirusTotal (la búsqueda por hash no sube el fichero).
3. Extraer metadatos (`exiftool`): autor, fechas, software.
4. Extraer cadenas legibles (`strings`) y URL/IP incrustadas.
5. Analizar las macros con `olevba` (oletools): autoejecución (AutoOpen), llamadas a shell o PowerShell, descargas.
6. Documentar los IOC obtenidos (URL, IP, hash, nombres de fichero, claves de registro).

**Preparación (inofensiva).** En VM-WIN, abre Word (o LibreOffice) y crea un documento con esta macro, guárdalo como *Nomina_Noviembre_2026.docm* y cópialo a VM-KALI (carpeta compartida o arrastrar y soltar). No contiene nada malicioso: solo muestra un mensaje.

```text
Sub AutoOpen()
    MsgBox "Simulacion TP ciberseguridad - macro inofensiva"
End Sub
```

Si no dispones de Word ni LibreOffice, analiza solo el fichero EICAR de la práctica B y deja constancia de ello en el informe.

**En VM-KALI** (instala oletools si no está: `sudo apt install python3-oletools` o `pip install oletools`):

```text
file Nomina_Noviembre_2026.docm
sha256sum Nomina_Noviembre_2026.docm
exiftool Nomina_Noviembre_2026.docm | head -20
strings -n 8 Nomina_Noviembre_2026.docm | head -30
olevba Nomina_Noviembre_2026.docm
```

> **Captura 3.3** — Análisis estático del documento con macros (file, hash, exiftool)
>
> - **Qué capturar:** Salida de file, sha256sum y exiftool sobre el documento .docm de prueba.
> - **Máquina / entorno:** VM-KALI, terminal.
> - **Herramienta / comando:** `file ...docm`, `sha256sum ...docm`, `exiftool ...docm | head -20`
> - **Debe verse:** El tipo real de fichero, el hash SHA-256 completo y los metadatos (software, fechas). **Apunta el hash: lo necesitas en la ficha y en la cadena de custodia.**
>
> ![Figura 3.3. Análisis estático del documento con macros (file, hash, exiftool)](../evidence/3.3.png)

> **Captura 3.4** — Análisis de macros con olevba
>
> - **Qué capturar:** El informe de olevba, donde se vea la detección de la macro AutoOpen y la clasificación de palabras clave sospechosas.
> - **Máquina / entorno:** VM-KALI, terminal.
> - **Herramienta / comando:** `olevba Nomina_Noviembre_2026.docm`
> - **Debe verse:** La macro extraída, y la tabla de «Type / Keyword / Description» con AutoExec (AutoOpen) y, si aparece, MsgBox como «Suspicious/Info».
>
> ![Figura 3.4. Análisis de macros con olevba](../evidence/3.4.png)

> **Captura 3.5** — Consulta del hash de EICAR en VirusTotal (búsqueda por hash)
>
> - **Qué capturar:** El resultado de buscar el SHA-256 del fichero EICAR (o del documento) en VirusTotal. Primero calcula el hash en VM-WIN con `Get-FileHash` o en Kali con `sha256sum`.
> - **Máquina / entorno:** ANFITRIÓN, navegador (virustotal.com). El hash se copia desde VM-KALI o VM-WIN.
> - **Herramienta / comando:** Pestaña Search, pegar el hash SHA-256. **No subas documentos reales con datos confidenciales.**
> - **Debe verse:** El hash buscado, el número de detecciones (EICAR lo detectan prácticamente todos los motores) y los nombres de la familia.
>
> ![Figura 3.5. Consulta del hash de EICAR en VirusTotal (búsqueda por hash)](../evidence/3.5.png)


## 3.5 Análisis de las conexiones sospechosas

Se busca responder a cinco preguntas: ¿qué proceso hizo la conexión?, ¿a dónde?, ¿cuándo y con qué frecuencia?, ¿cuántos datos se movieron? y ¿qué otros equipos hablan con el mismo destino? En el equipo vivo se usan `netstat` o TCPView para relacionar la conexión con un proceso (PID), y en el tráfico capturado, Wireshark para ver la periodicidad.

**En VM-WIN**, con el beaconing en marcha (el proceso será powershell.exe):

```text
netstat -ano | findstr 192.168.56.10
tasklist /fi "PID eq <PID_obtenido>"
Get-NetTCPConnection -RemoteAddress 192.168.56.10 | Select LocalPort,RemotePort,State,OwningProcess
```

> **Captura 3.6** — Relación conexión-proceso en el equipo (netstat/TCPView)
>
> - **Qué capturar:** La conexión hacia 192.168.56.10:8000 asociada a un PID y su proceso (powershell.exe).
> - **Máquina / entorno:** VM-WIN, PowerShell o CMD como administrador (o TCPView de Sysinternals).
> - **Herramienta / comando:** `netstat -ano | findstr 192.168.56.10` y `tasklist /fi "PID eq <PID>"`. Alternativa gráfica: TCPView.
> - **Debe verse:** La IP remota, el puerto, el estado y el nombre del proceso. Mejor si se ve la línea que une PID y proceso.
>
> ![Figura 3.6. Relación conexión-proceso en el equipo (netstat/TCPView)](../evidence/3.6.png)

**En VM-KALI**, abre el fichero `~/beacon.pcap` en Wireshark y analiza:

- Statistics > Conversations > pestaña TCP/IPv4: bytes y paquetes entre 192.168.56.20 y 192.168.56.10.
- Filtro `http.request.uri contains "beacon"` y columna «Time since previous displayed frame» (View > Time Display Format) para ver los ~10 s.
- Botón derecho sobre un paquete > Follow > HTTP Stream para ver la petición completa.
- Statistics > I/O Graph para visualizar el patrón periódico.

> **Captura 3.7** — Análisis de periodicidad y conversaciones en Wireshark
>
> - **Qué capturar:** El patrón de beaconing en el pcap: lista de paquetes filtrada y la gráfica de E/S o las conversaciones.
> - **Máquina / entorno:** VM-KALI, Wireshark con ~/beacon.pcap abierto.
> - **Herramienta / comando:** Filtro `http.request.uri contains "beacon"` + Statistics > I/O Graph (o Conversations).
> - **Debe verse:** Peticiones regulares cada ~10 s y, en la gráfica o la tabla, la regularidad que delata al beaconing.
>
> ![Figura 3.7. Análisis de periodicidad y conversaciones en Wireshark](../evidence/3.7.png)


## 3.6 Cálculo del hash SHA-256 y su utilidad

SHA-256 genera una huella de 256 bits (64 caracteres hexadecimales). Su utilidad en un incidente: (1) **integridad** de las evidencias, (2) **identificación** inequívoca de un fichero malicioso y su búsqueda en bases de datos de amenazas, (3) **cadena de custodia**: demostrar que una evidencia no ha cambiado, (4) detectar duplicados y ficheros alterados, y (5) validez probatoria ante un juzgado o la AEPD.

```text
# En VM-KALI
echo "Evidencia 001 - informe de prueba" > evidencia.txt
sha256sum evidencia.txt
echo "." >> evidencia.txt            # cambiar un único carácter
sha256sum evidencia.txt              # el hash cambia por completo (efecto avalancha)
```

> **Captura 3.8** — SHA-256 en Linux y efecto avalancha
>
> - **Qué capturar:** El hash de evidencia.txt antes y después de modificar un solo carácter, mostrando que los hashes son totalmente distintos.
> - **Máquina / entorno:** VM-KALI, terminal.
> - **Herramienta / comando:** `sha256sum evidencia.txt` (dos veces, antes y después del cambio).
> - **Debe verse:** Ambos hashes completos en la misma captura.
>
> ![Figura 3.8. SHA-256 en Linux y efecto avalancha](../evidence/3.8.png)

Para demostrar que el hash es independiente del sistema operativo, copia la **versión original** del fichero a VM-WIN (guárdala antes de modificarla, por ejemplo como evidencia_original.txt) y calcula su hash con PowerShell:

```text
Get-FileHash -Algorithm SHA256 .\evidencia_original.txt
# alternativa clásica: certutil -hashfile evidencia_original.txt SHA256
```

> **Captura 3.9** — SHA-256 en Windows: coincidencia con el hash de Linux
>
> - **Qué capturar:** El hash de evidencia_original.txt en Windows y, a su lado o en el informe, el hash de Linux del mismo fichero para comprobar que coinciden.
> - **Máquina / entorno:** VM-WIN, PowerShell.
> - **Herramienta / comando:** `Get-FileHash -Algorithm SHA256 .\evidencia_original.txt`
> - **Debe verse:** El hash completo (64 hex), el algoritmo SHA256 y el nombre del archivo. Resalta que coincide con el de Linux.
>
> ![Figura 3.9. SHA-256 en Windows: coincidencia con el hash de Linux](../evidence/3.9.png)


## 3.7 Preservación forense y cadena de custodia

Para practicar la preservación, se crea una «imagen forense» de un disco de pruebas pequeño con `dd` y se comprueba su integridad con hash. En un caso real se haría con FTK Imager o dd sobre el disco de WS-ADM-07 con bloqueo de escritura.

```text
# En VM-KALI: crear un disco de pruebas de 50 MB con un fichero dentro
dd if=/dev/zero of=disco_pruebas.img bs=1M count=50
mkfs.ext4 -q disco_pruebas.img
mkdir -p mnt && sudo mount -o loop disco_pruebas.img mnt
echo "dato del cliente" | sudo tee mnt/cliente.txt && sudo umount mnt

# Adquisición: copia bit a bit + verificación
sha256sum disco_pruebas.img | tee hash_origen.txt
dd if=disco_pruebas.img of=imagen_forense.img bs=4M status=progress
sha256sum imagen_forense.img | tee hash_copia.txt
chmod 444 imagen_forense.img          # solo lectura
```

> **Captura 3.10** — Adquisición de una imagen forense y verificación del hash
>
> - **Qué capturar:** Los dos hashes SHA-256 (origen y copia) idénticos tras la copia con dd, y la imagen marcada como solo lectura.
> - **Máquina / entorno:** VM-KALI, terminal.
> - **Herramienta / comando:** `sha256sum disco_pruebas.img`, `dd if=... of=imagen_forense.img`, `sha256sum imagen_forense.img`, `ls -l`
> - **Debe verse:** Ambos hashes iguales, y el listado con permisos -r--r--r-- en la imagen.
>
> ![Figura 3.10. Adquisición de una imagen forense y verificación del hash](../evidence/3.10.png)

> **Captura 3.11** — Volcado de memoria RAM del equipo (FTK Imager) *(opcional)*
>
> - **Qué capturar:** FTK Imager en proceso o finalizado del volcado de memoria de VM-WIN, indicando el fichero .mem generado y su tamaño. Después calcula su hash SHA-256.
> - **Máquina / entorno:** VM-WIN (da al menos 2-4 GB de RAM a la máquina virtual).
> - **Herramienta / comando:** FTK Imager > File > Capture Memory. Guarda el fichero en una carpeta distinta del sistema. Hash: `Get-FileHash memdump.mem`
> - **Debe verse:** El destino del fichero, el tamaño y el hash. Si no puedes instalar FTK Imager, indícalo en el informe y explica el procedimiento teórico.
>
> ![Figura 3.11. Volcado de memoria RAM del equipo (FTK Imager)](../evidence/3.11.png)


### Documentación de la cadena de custodia

La cadena de custodia es el registro cronológico e ininterrumpido de quién ha tenido cada evidencia, cuándo, dónde, con qué fin y en qué estado. Se documenta con una ficha por evidencia y una tabla de movimientos. Plantilla rellenada con datos del caso (ficticio):

| Campo | Valor |
|---|---|
| ID de evidencia | EV-001 |
| Descripción | Imagen forense del disco SSD 512 GB del equipo WS-ADM-07 (S/N: [número de serie]) |
| Incidente | INC-2026-001 |
| Obtenida por / fecha y hora | [tu nombre], 16/11/2026 13:05 (hora de Madrid, equipo sincronizado por NTP) |
| Lugar de recogida | Puesto de trabajo de Administración, planta 2 |
| Método | FTK Imager con bloqueo de escritura; formato E01 |
| Hash SHA-256 de origen / de la copia | [SHA-256 origen] / [SHA-256 copia] - coinciden |
| Almacenamiento | Copia de trabajo en repositorio forense cifrado y de solo lectura; original en caja precintada nº 1, armario de seguridad |

| Fecha y hora | Entrega de | Recibe | Motivo | Estado / hash verificado | Firmas |
|---|---|---|---|---|---|
| 16/11 13:05 | Responsable TI | Resp. ciberseguridad | Adquisición de la evidencia | Original intacto; hash calculado | [firma] / [firma] |
| 16/11 15:30 | Resp. ciberseguridad | Analista forense | Análisis de la copia | Hash verificado: coincide | [firma] / [firma] |
| 17/11 09:00 | Analista forense | Caja de seguridad | Custodia tras el análisis | Precintada, nº de precinto 0001 | [firma] / [firma] |
| [fecha] | [nombre] | [nombre] | [motivo: p. ej., entrega a la autoridad] | [estado] | [firma] / [firma] |


---

# 4. Respuesta y recuperación


## 4.1 Procedimiento de actuación

Orden de las fases: **contener primero, erradicar después**. Si se elimina el malware antes de entender el alcance, el atacante puede cambiar de táctica y se pierden evidencias. Cada fase tiene responsable, acciones y criterio de finalización.

| Fase | Acciones | Responsable | Criterio de cierre |
|---|---|---|---|
| 1. Aislamiento de los equipos afectados | • Aislar WS-ADM-07 de la red (aislamiento desde el EDR o desconexión del cable/puerto del switch/VLAN de cuarentena). **No apagar**: se pierde la memoria.<br>• Volcar memoria y tomar imagen antes de cualquier limpieza (apartado 3).<br>• Identificar a los otros 13 receptores del correo y aislar los que lo abrieron.<br>• Segmentar o restringir temporalmente el acceso a SRV-FICHEROS y a los datos de clientes. | Informática + ciberseguridad | Ningún equipo afectado puede comunicarse con la red interna ni con Internet. |
| 2. Bloqueo de conexiones maliciosas | • Bloquear en el firewall (entrada y salida) 203.0.113.45 y 198.51.100.23.<br>• Bloquear en DNS/proxy cdn-update-delta.example y rrhh-solucionesdelta.example (sinkhole).<br>• En la pasarela de correo: bloquear el remitente y dominio; **retirar el correo de todos los buzones** (búsqueda y purga).<br>• Bloquear por hash el adjunto en el antivirus/EDR.<br>• Vigilar los intentos bloqueados: indican otros equipos infectados. | Redes + ciberseguridad | Reglas aplicadas y verificadas; sin tráfico saliente hacia los IOC. |
| 3. Revocación de credenciales comprometidas | • Restablecer contraseña y cerrar sesiones activas del usuario afectado (revocar tokens, cerrar sesiones en la nube).<br>• Si el equipo tuvo sesiones de administración o se sospecha de robo de credenciales de dominio: restablecer también las cuentas de servicio y privilegiadas, y **krbtgt dos veces** si hay indicios de compromiso del dominio.<br>• Revocar claves API, certificados y VPN asociados. Activar MFA en todas las cuentas.<br>• Revisar reglas de reenvío de correo y aplicaciones OAuth creadas por el atacante. | Administración de sistemas + ciberseguridad | Todas las credenciales expuestas renovadas; sin inicios de sesión sospechosos posteriores. |
| 4. Eliminación de la amenaza (erradicación) | • Determinar el alcance completo (búsqueda de IOC en toda la flota con el EDR).<br>• Buscar persistencia: tareas programadas, claves Run, servicios, WMI, carpetas de inicio, usuarios nuevos.<br>• Eliminar el malware. **Preferible reinstalar el equipo desde imagen limpia** en lugar de «limpiar».<br>• Parchear la vulnerabilidad o debilidad explotada (macros habilitadas, falta de filtrado, etc.).<br>• Ventana de erradicación **coordinada**: se actúa a la vez sobre todos los equipos comprometidos para que el atacante no se reorganice. | Ciberseguridad + informática | Escaneos limpios, sin persistencia ni conexiones a IOC durante 72 h de observación. |
| 5. Recuperación de sistemas y servicios | • Restaurar desde copias de seguridad **anteriores** al compromiso y verificadas (hash, antivirus).<br>• Reincorporar los servicios por prioridad de negocio (correo, ficheros, CRM) con vigilancia reforzada.<br>• Reconectar equipos reinstalados de forma escalonada.<br>• Monitorización intensiva 2-4 semanas: alertas ampliadas y revisión diaria de logs. | Informática + ciberseguridad + dirección | Servicios operativos, sin reaparición de IOC, usuarios confirman funcionamiento. |
| 6. Medidas para evitar nuevos incidentes | • Deshabilitar macros por política (GPO) y activar reglas ASR de Defender.<br>• Implantar SPF, DKIM y DMARC (con política reject) y marcar los correos externos.<br>• MFA generalizado, mínimo privilegio y revisión de permisos en carpetas de clientes.<br>• EDR en todos los equipos y SIEM con alertas; copias 3-2-1 inmutables.<br>• Segmentación de red y filtrado de salida (egress).<br>• Plan de respuesta a incidentes formal, ejercicios de mesa y formación continua (apartado 1). | Dirección + ciberseguridad | Plan de mejora aprobado con responsables y fechas. |


## 4.2 Práctica de laboratorio: ejecución de la respuesta

Las siguientes pruebas reproducen en VM-WIN los pasos del procedimiento. Parte de la instantánea limpia y deja de nuevo en marcha el beaconing de la práctica A (apartado 2) antes de empezar.


### Aislamiento del equipo

```text
# VM-WIN, PowerShell administrador
ping 192.168.56.10 -n 3                       # antes: responde
Get-NetAdapter                                # anota el nombre, p. ej. "Ethernet"
Disable-NetAdapter -Name "Ethernet" -Confirm:$false
ping 192.168.56.10 -n 3                       # después: sin conexión
# Para restaurar tras la prueba: Enable-NetAdapter -Name "Ethernet"
```

> **Captura 4.1** — Aislamiento del equipo infectado
>
> - **Qué capturar:** El ping a 192.168.56.10 antes y después de deshabilitar el adaptador de red, con el estado del adaptador en Disabled.
> - **Máquina / entorno:** VM-WIN, PowerShell como administrador.
> - **Herramienta / comando:** `ping 192.168.56.10 -n 3`, `Disable-NetAdapter -Name "Ethernet" -Confirm:$false`, `Get-NetAdapter`
> - **Debe verse:** Respuestas del ping antes, el fallo (tiempo de espera / host inaccesible) después y el adaptador deshabilitado. Vuelve a habilitar el adaptador al terminar.
>
> ![Figura 4.1. Aislamiento del equipo infectado](../evidence/4.1.png)


### Bloqueo de conexiones maliciosas

```text
# Con la red habilitada de nuevo y el beaconing en marcha
New-NetFirewallRule -DisplayName "IR-INC001 Bloqueo C2" -Direction Outbound `
    -RemoteAddress 192.168.56.10 -Action Block
Get-NetFirewallRule -DisplayName "IR-INC001*" | Format-Table DisplayName,Direction,Action,Enabled
```

> **Captura 4.2** — Bloqueo de la IP maliciosa en el firewall
>
> - **Qué capturar:** La regla de firewall creada y el efecto: el beaconing empieza a fallar y el servidor de VM-KALI deja de recibir peticiones.
> - **Máquina / entorno:** VM-WIN (PowerShell administrador y ventana del beaconing con errores) y/o VM-KALI (terminal del servidor sin nuevas peticiones).
> - **Herramienta / comando:** `New-NetFirewallRule -DisplayName "IR-INC001 Bloqueo C2" -Direction Outbound -RemoteAddress 192.168.56.10 -Action Block`
> - **Debe verse:** La regla (Action Block, Enabled True) y, en la misma captura o en otra, la evidencia de que ya no hay peticiones nuevas en Kali.
>
> ![Figura 4.2. Bloqueo de la IP maliciosa en el firewall](../evidence/4.2.png)


### Revocación de credenciales

```text
# Se crea un usuario de laboratorio "comprometido"
net user usuario_victima Passw0rd!Lab /add
# Respuesta: deshabilitar, cambiar clave y comprobar
Disable-LocalUser -Name "usuario_victima"
net user usuario_victima "N0va-Clave_Segura#2026"
Get-LocalUser usuario_victima | Format-List Name,Enabled,PasswordLastSet
klist purge                                  # (en dominio) purgar tickets Kerberos
```

> **Captura 4.3** — Revocación de credenciales comprometidas
>
> - **Qué capturar:** La cuenta de laboratorio deshabilitada y con la contraseña cambiada (fecha de último cambio actualizada).
> - **Máquina / entorno:** VM-WIN, PowerShell administrador.
> - **Herramienta / comando:** `Disable-LocalUser`, `net user ...`, `Get-LocalUser usuario_victima | Format-List Name,Enabled,PasswordLastSet`
> - **Debe verse:** Enabled = False y PasswordLastSet con la fecha y hora actuales. Explica en el texto que en el entorno real sería un restablecimiento en Active Directory.
>
> ![Figura 4.3. Revocación de credenciales comprometidas](../evidence/4.3.png)


### Eliminación de la amenaza y de la persistencia

```text
# 1) Simular persistencia inofensiva (tarea programada)
schtasks /create /tn "ActualizacionLab" /tr "powershell.exe -Command Start-Sleep 1" /sc onlogon
# 2) Detectarla: Autoruns (Sysinternals) o
schtasks /query /tn "ActualizacionLab" /v /fo list
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run
# 3) Eliminarla y verificar
schtasks /delete /tn "ActualizacionLab" /f
schtasks /query /tn "ActualizacionLab"       # debe dar error: no existe
# 4) Análisis completo con Defender
Start-MpScan -ScanType QuickScan; Get-MpThreatDetection
```

> **Captura 4.4** — Detección de la persistencia (Autoruns o schtasks)
>
> - **Qué capturar:** La tarea programada «ActualizacionLab» localizada con Autoruns (pestaña Scheduled Tasks) o con schtasks.
> - **Máquina / entorno:** VM-WIN. Autoruns se descarga desde Sysinternals; ejecútalo como administrador.
> - **Herramienta / comando:** Autoruns > pestaña Scheduled Tasks, o `schtasks /query /tn "ActualizacionLab" /v /fo list`
> - **Debe verse:** El nombre de la tarea, su comando y el usuario. Es el equivalente a la persistencia de un malware real.
>
> ![Figura 4.4. Detección de la persistencia (Autoruns o schtasks)](../evidence/4.4.png)

> **Captura 4.5** — Eliminación de la persistencia y análisis de Defender
>
> - **Qué capturar:** La tarea eliminada (la consulta posterior da error) y el resultado del análisis rápido de Defender.
> - **Máquina / entorno:** VM-WIN, PowerShell administrador.
> - **Herramienta / comando:** `schtasks /delete /tn "ActualizacionLab" /f`, `schtasks /query ...`, `Start-MpScan -ScanType QuickScan`, `Get-MpThreatDetection`
> - **Debe verse:** El mensaje de éxito al borrar, el error al consultar de nuevo y el análisis completado.
>
> ![Figura 4.5. Eliminación de la persistencia y análisis de Defender](../evidence/4.5.png)


### Recuperación del sistema

En el laboratorio, la recuperación equivale a volver a un estado limpio conocido. En un caso real, WS-ADM-07 se reinstalaría desde una imagen corporativa y los datos se restaurarían desde una copia anterior al compromiso, escaneada y verificada con hash.

> **Captura 4.6** — Restauración de VM-WIN al estado limpio
>
> - **Qué capturar:** El gestor de instantáneas del hipervisor con la instantánea «Estado limpio» y la restauración realizada. A continuación, comprueba que ya no hay beaconing ni la tarea programada.
> - **Máquina / entorno:** ANFITRIÓN (VirtualBox: Máquina > Instantáneas > Restaurar; VMware: VM > Snapshot > Revert).
> - **Herramienta / comando:** Gestor de instantáneas del hipervisor. Dentro de VM-WIN, `schtasks /query /tn "ActualizacionLab"` debe dar error.
> - **Debe verse:** La instantánea restaurada y, si cabe, la comprobación de que el sistema vuelve a estar limpio.
>
> ![Figura 4.6. Restauración de VM-WIN al estado limpio](../evidence/4.6.png)


### Medida preventiva: reglas de reducción de superficie de ataque (ASR)

Una de las medidas de prevención del punto 6 es bloquear que Office cree procesos hijos y que el correo ejecute contenido. Con Defender se hace así:

```text
# Bloquear que las aplicaciones de Office creen procesos secundarios
Add-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A `
    -AttackSurfaceReductionRules_Actions Enabled
# Bloquear contenido ejecutable desde cliente de correo y webmail
Add-MpPreference -AttackSurfaceReductionRules_Ids BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550 `
    -AttackSurfaceReductionRules_Actions Enabled
Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Ids
```

> **Captura 4.7** — Reglas ASR de Defender habilitadas
>
> - **Qué capturar:** Las reglas ASR configuradas y verificadas.
> - **Máquina / entorno:** VM-WIN, PowerShell administrador (requiere Defender activo).
> - **Herramienta / comando:** `Add-MpPreference -AttackSurfaceReductionRules_Ids ... -AttackSurfaceReductionRules_Actions Enabled` y `Get-MpPreference | Select AttackSurfaceReductionRules_Ids,AttackSurfaceReductionRules_Actions`
> - **Debe verse:** Los GUID de las reglas con acción 1 (Enabled).
>
> ![Figura 4.7. Reglas ASR de Defender habilitadas](../evidence/4.7.png)


## 4.3 Ciberresiliencia: anticipación, resistencia, recuperación y evolución

La ciberresiliencia es la capacidad de una organización para anticiparse a los ataques, resistirlos, recuperarse y aprender de ellos, asegurando la continuidad del negocio. Se alinea con los objetivos de NIST SP 800-160 vol. 2 (anticipate, withstand, recover, adapt). Aplicación en Soluciones Delta:

| Principio | Qué significa | Cómo lo aplico |
|---|---|---|
| Anticipación | Prepararse antes de que ocurra el incidente | Análisis de riesgos, inventario de activos, inteligencia de amenazas (INCIBE, CCN-CERT), plan de respuesta aprobado, formación y simulacros de phishing, ejercicios de mesa, contactos de emergencia (CSIRT, DPO, asesoría legal, seguro cibernético). |
| Resistencia | Evitar o limitar el impacto cuando el ataque ocurre | Defensa en profundidad: MFA, mínimo privilegio, macros bloqueadas, EDR, filtrado de correo, segmentación de red, cifrado de datos, parches, aislamiento rápido de equipos. |
| Recuperación | Volver a operar con rapidez y seguridad | Copias 3-2-1 inmutables y probadas, imágenes limpias, objetivos RTO/RPO por servicio, plan de continuidad de negocio, restauración escalonada y vigilancia reforzada. |
| Evolución | Aprender y mejorar | Análisis post-incidente (lecciones aprendidas), actualización del plan, métricas (tiempo de detección y de respuesta), ajuste de reglas de detección y de la formación, revisión de la política de seguridad. |

**Lecciones aprendidas previstas:** reunión de cierre en un plazo máximo de 2 semanas con todos los implicados; informe final con cronología, causa raíz, qué funcionó y qué falló, coste del incidente y plan de acción con responsable y fecha para cada mejora.


---

# 5. Notificación y organismos de respuesta


## 5.1 Modelo de comunicación interna del incidente

Principios: **mínimo necesario** (solo se informa a quien lo necesita), **un único portavoz**, información verificada y sin especulaciones, y canal alternativo si el correo corporativo puede estar comprometido (teléfono o mensajería segura).

| Destinatario | Contenido | Canal | Cuándo |
|---|---|---|---|
| Equipo de respuesta (CSIRT interno) | Detalle técnico completo, tareas y turnos | Canal seguro / reunión | Inmediato y continuo |
| Dirección general y DPO | Resumen de situación, impacto, riesgo legal, decisiones que se requieren | Llamada + informe breve | En 1 h y cada vez que haya cambios |
| Resto de empleados | Instrucciones prácticas (qué hacer y qué no), sin detalles técnicos | Comunicado de TI | Cuando se contenga lo esencial |
| Empleados afectados (receptores del correo) | Pasos concretos: no abrir, desconectar, cambiar claves, avisar | Llamada o presencial | Inmediato |
| Comunicación / atención al cliente | Mensaje oficial preparado, preguntas frecuentes | Reunión | Tras valorar la brecha |


### Plantilla A. Aviso interno inicial al equipo de respuesta y a la dirección

```text
ASUNTO: [CONFIDENCIAL] INC-2026-001 - Incidente de seguridad en curso
Fecha y hora: 16/11/2026 11:40     Elaborado por: [tu nombre], Resp. Ciberseguridad

RESUMEN: Se ha detectado la ejecución de un adjunto malicioso recibido por correo
(falso mensaje de RR. HH.) en el equipo WS-ADM-07, con conexiones salientes a IP
externas y accesos sospechosos a la carpeta de clientes.
GRAVEDAD: Alta (potencialmente crítica). Prioridad P1.
IMPACTO CONOCIDO: 1 equipo afectado. 13 equipos más en revisión.
RIESGO: Posible fuga de datos personales de clientes (pendiente de confirmar).
ACCIONES EN CURSO: aislamiento del equipo, bloqueo de IOC, preservación de evidencias.
SE REQUIERE: reunión de crisis a las 12:15 (sala de reuniones / videollamada).
INSTRUCCIONES: no reenviar este mensaje. No comentar el incidente fuera del equipo.
PRÓXIMA ACTUALIZACIÓN: 13:30 o antes si hay novedades.
```


### Plantilla B. Comunicado a todos los empleados

```text
ASUNTO: Aviso de seguridad: correo falso de "Recursos Humanos"

Hola a todos:
Hoy se ha recibido un correo fraudulento con el asunto "Actualización de nómina -
acción requerida". NO es de Recursos Humanos.
- Si NO lo has abierto: elimínalo y no hagas clic en nada.
- Si LO HAS ABIERTO o has habilitado macros: desconecta el equipo de la red SIN
  apagarlo y llama ya a TI (ext. 1234). No pasa nada por avisar.
- No uses el correo para comentar el incidente; contacta con TI.
Gracias por vuestra colaboración. Seguiremos informando.
Seguridad TI
```


### Plantilla C. Resumen para la dirección y el DPO (decisión sobre notificación)

| Campo | Contenido |
|---|---|
| Hechos conocidos | Ejecución de malware, conexiones C2, intentos de acceso a datos de clientes |
| Datos potencialmente afectados | Categorías, nº aproximado de clientes y registros, sensibilidad |
| Evidencias de exfiltración | Volumen saliente, ficheros accedidos, confirmado / no confirmado |
| Riesgo para los afectados | Valoración (bajo / medio / alto) y justificación |
| Decisiones requeridas | Notificación a la AEPD, comunicación a afectados, denuncia, contratación de apoyo externo |
| Plazo | Momento de conocimiento: [fecha y hora]. Límite de 72 h: [fecha y hora] |


## 5.2 Notificación de una brecha de datos personales a la AEPD

El Reglamento General de Protección de Datos (RGPD, Reglamento UE 2016/679) y la LOPDGDD (Ley Orgánica 3/2018) definen una **violación de la seguridad de los datos personales** como la destrucción, pérdida o alteración accidental o ilícita de datos personales, o la comunicación o acceso no autorizados a ellos.

- **Cuándo notificar a la AEPD (art. 33 RGPD):** cuando exista una brecha de seguridad que afecte a datos personales, **salvo que sea improbable que suponga un riesgo** para los derechos y libertades de las personas.
- **Plazo:** sin dilación indebida y, si es posible, **en un máximo de 72 horas** desde que el responsable tiene constancia de la brecha. Si se supera, hay que justificar el retraso. Se admite notificación **por fases** si no se dispone de toda la información.
- **Contenido mínimo:** naturaleza de la brecha (categorías y nº aproximado de afectados y de registros), datos de contacto del DPO, posibles consecuencias y medidas adoptadas o propuestas.
- **Comunicación a los afectados (art. 34):** cuando la brecha entrañe un **alto riesgo**, se debe informar a los interesados «sin dilación indebida», en lenguaje claro. Excepciones: datos cifrados ininteligibles, medidas posteriores que eliminan el riesgo, o esfuerzo desproporcionado (con comunicación pública).
- **Registro interno (art. 33.5):** toda brecha, se notifique o no, debe documentarse (hechos, efectos y medidas).
- **Encargados del tratamiento:** deben avisar al responsable sin dilación indebida (art. 33.2).
- **Cómo:** a través de la sede electrónica de la AEPD (formulario de notificación de brechas). La AEPD ofrece una guía sobre gestión y notificación de brechas y una herramienta orientativa de ayuda a la decisión («Asesora Brecha»).


### Aplicación al caso

En este incidente hay indicios razonables de acceso no autorizado y posible exfiltración de datos personales de clientes (identificación, contacto y, posiblemente, facturación). Mientras no se pueda **descartar** el acceso a esos datos, se trata como brecha potencial. El reloj de las 72 horas empieza cuando existe **certeza razonable** de que ha habido compromiso de datos personales (no al inicio del incidente), pero se documenta cuándo y por qué se llegó a esa conclusión. Si se confirma la extracción de datos no cifrados y con información identificativa y financiera, el riesgo es alto: **se notifica a la AEPD y se comunica a los clientes afectados**. Si el análisis de logs demuestra que no se accedió a datos personales, se registra internamente la decisión de no notificar, razonada.

> [!TIP]
> **Qué haría yo**
> Activar al DPO desde la primera hora, abrir el registro de brechas, fijar la hora de conocimiento, preparar una notificación inicial a la AEPD dentro de las 72 h con los datos disponibles y completarla por fases. En paralelo, valorar denuncia ante las Fuerzas y Cuerpos de Seguridad (Policía Nacional o Guardia Civil) y avisar a la aseguradora de ciberriesgos y a los clientes con obligaciones contractuales de aviso.


## 5.3 Organismos CERT/CSIRT y sus funciones

Un **CERT/CSIRT** (Computer Emergency / Security Incident Response Team) es un equipo especializado en prevenir, detectar, analizar y responder a incidentes de ciberseguridad. Sus funciones habituales son: gestión y coordinación de incidentes, alerta temprana y avisos de vulnerabilidades, análisis de malware y forense, apoyo técnico a las víctimas, difusión de buenas prácticas y formación, y cooperación nacional e internacional.

| Equipo | Ámbito | Funciones y utilidad para la empresa |
|---|---|---|
| INCIBE-CERT (Instituto Nacional de Ciberseguridad) | España: ciudadanos, empresas (pymes) y entidades privadas; operadores de ámbito no público | Notificación y gestión de incidentes de empresas, avisos y vulnerabilidades, línea de ayuda en ciberseguridad (017), recursos para pymes. Es el equipo de referencia para Soluciones Delta. |
| CCN-CERT (Centro Criptológico Nacional) | España: Administraciones públicas, empresas y organizaciones estratégicas o críticas; Esquema Nacional de Seguridad | Respuesta a incidentes en el sector público y entidades críticas, guías CCN-STIC, herramientas (LUCIA, CARMEN, MARIA), alertas. Solo recurriría la empresa si fuera proveedor de la Administración o infraestructura crítica. |
| CERT-EU | Unión Europea: instituciones, órganos y agencias | Respuesta a incidentes e inteligencia para las instituciones de la UE. Referente de cooperación europea. |
| Red de CSIRT de la UE / ENISA | Estados miembros de la UE | Coordinación entre los CSIRT nacionales según la Directiva NIS2 y apoyo de la Agencia de Ciberseguridad de la UE (ENISA). |
| FIRST (Forum of Incident Response and Security Teams) | Internacional | Comunidad global de equipos de respuesta; intercambio de información y estándares. |
| CISA (EE. UU.) | EE. UU., con alcance internacional por su información | Alertas, guías y listas de vulnerabilidades explotadas conocidas (KEV); útil como fuente de inteligencia. |

> [!NOTE]
> **Los dos equipos que investigaría y a los que recurriría**
> **1) INCIBE-CERT**, por ser el equipo para empresas privadas en España, con canal de notificación de incidentes y línea 017. **2) CCN-CERT**, como referente nacional técnico (guías CCN-STIC, análisis de amenazas y colaboración) y obligatorio si la empresa fuera proveedor de organismos públicos. Como alternativa internacional se menciona **CERT-EU**. Comprueba en sus webs oficiales el procedimiento de contacto vigente antes de entregar el trabajo.

> **Captura 5.1** — Web de INCIBE-CERT: notificación de incidentes y línea de ayuda 017
>
> - **Qué capturar:** La página oficial de INCIBE-CERT o INCIBE (incibe.es) donde se vea cómo notificar un incidente y el teléfono 017.
> - **Máquina / entorno:** ANFITRIÓN, navegador.
> - **Herramienta / comando:** Busca en incibe.es «INCIBE-CERT», «Notificar un incidente» o «Línea de ayuda en ciberseguridad 017».
> - **Debe verse:** La URL completa en la barra de direcciones, el título de la página y la información de contacto o notificación.
>
> ![Figura 5.1. Web de INCIBE-CERT: notificación de incidentes y línea de ayuda 017](../evidence/5.1.png)

> **Captura 5.2** — Web del CCN-CERT
>
> - **Qué capturar:** La web oficial del CCN-CERT (ccn-cert.cni.es) con la descripción de sus servicios y su ámbito de actuación.
> - **Máquina / entorno:** ANFITRIÓN, navegador.
> - **Herramienta / comando:** Busca en ccn-cert.cni.es la sección de servicios o «Gestión de incidentes».
> - **Debe verse:** La URL, el nombre del servicio y su descripción.
>
> ![Figura 5.2. Web del CCN-CERT](../evidence/5.2.png)

> **Captura 5.3** — Notificación de brechas en la sede electrónica de la AEPD
>
> - **Qué capturar:** La página de la AEPD sobre brechas de seguridad: notificación, plazos y guía.
> - **Máquina / entorno:** ANFITRIÓN, navegador.
> - **Herramienta / comando:** aepd.es > busca «brechas de datos personales» / «notificar una brecha de seguridad».
> - **Debe verse:** La URL, el título y los textos con el plazo de 72 horas y la forma de notificar.
>
> ![Figura 5.3. Notificación de brechas en la sede electrónica de la AEPD](../evidence/5.3.png)

> **Captura 5.4** — Web de CERT-EU (equipo internacional de referencia)
>
> - **Qué capturar:** La página oficial de CERT-EU (cert.europa.eu) con la descripción de su misión y servicios.
> - **Máquina / entorno:** ANFITRIÓN, navegador.
> - **Herramienta / comando:** Busca en cert.europa.eu la sección «About us» o «Services».
> - **Debe verse:** La URL, la misión de CERT-EU y los servicios principales.
>
> ![Figura 5.4. Web de CERT-EU (equipo internacional de referencia)](../evidence/5.4.png)


---

# 6. Simulación: reunión del equipo de respuesta a incidentes


## 6.1 Participantes y reglas

| Rol | Persona (ficticia) | Responsabilidad en la reunión |
|---|---|---|
| Responsable de ciberseguridad (modera) | [tu nombre] | Dirige, prioriza y justifica las decisiones técnicas |
| Analista forense / SOC | Laura Gómez | Evidencias, logs, alcance técnico |
| Administrador de sistemas y redes | Pablo Ruiz | Aislamiento, bloqueos, restauración |
| Delegado de protección de datos (DPO) | Marta Ortega | Brecha de datos y notificaciones |
| Director general | Javier Molina | Decisiones de negocio y recursos |
| Comunicación / RR. HH. | Elena Sanz | Comunicación interna y con clientes |

Regla de la reunión: breve y ordenada, cada intervención con una decisión o una petición de información. Se decide con la información disponible y se revisa cuando llegan novedades.


## 6.2 Guion de la simulación


### Apertura (estado inicial, 12:15)

**Responsable de ciberseguridad:** Buenas, empezamos. Estado: un equipo, WS-ADM-07, ejecutó un adjunto malicioso a las 09:31. Hay conexiones salientes a 203.0.113.45, alerta de antivirus e intentos de acceso a \\\\SRV-FICHEROS\\Clientes. 13 usuarios más recibieron el correo. Prioridad: contener sin destruir evidencias. Pablo, ¿qué has hecho?

**Pablo (sistemas):** WS-ADM-07 está aislado en la VLAN de cuarentena y apagado el WiFi. He bloqueado la IP y el dominio en el firewall y el DNS. No he apagado el equipo.

**Laura (forense):** He volcado la memoria y estoy haciendo la imagen del disco, con hash. Tengo los logs del firewall desde las 09:00 conservados.

**Responsable:** Bien. Marta, abre el registro de brechas y anota la hora de conocimiento. Elena, prepara el comunicado interno. Seguimos.


### Giro 1: se descubre otro equipo infectado

**Laura:** Novedad: el EDR muestra la misma firma en WS-COM-12, del departamento Comercial. Hizo clic a las 09:48 y también habla con el dominio cdn-update-delta.example. No lo había comunicado.

**Responsable:** Esto cambia el alcance: ya no es un incidente aislado. Decisiones: 1) aislar WS-COM-12 ahora; 2) lanzar una búsqueda de los IOC y el hash en toda la flota con el EDR y en los logs de DNS; 3) revisar inicios de sesión de red (4624 tipo 3) y accesos SMB entre los dos equipos para ver movimiento lateral; 4) restablecer las credenciales de los dos usuarios; 5) comprobar los 13 buzones y retirar el correo con una purga.

**Director:** ¿Por qué no basta con limpiar los dos ordenadores?

**Responsable:** Porque no sabemos aún si hay más equipos ni si se han robado credenciales. Limpiar sin entender el alcance da una falsa sensación de seguridad y el atacante vuelve a entrar. Elevo la prioridad a crítica y activo el protocolo de crisis.


### Giro 2: aparecen indicios de extracción de información

**Laura:** Hay un volumen anómalo: unos 2,3 GB salientes desde WS-ADM-07 hacia 203.0.113.45 entre las 11:05 y las 11:30. Además, en SRV-FICHEROS el usuario del empleado accedió a la carpeta Clientes con eventos 5145 sobre varios cientos de ficheros.

**Marta (DPO):** Si hay datos personales de clientes, es una brecha notificable. Necesito saber qué datos y cuántos afectados.

**Responsable:** Decisiones: 1) consideramos la fuga **probable** y fijamos la hora de conocimiento en este momento, por lo que el límite de 72 h es [fecha y hora de hoy +3 días]; 2) Laura cruza los 5145 con los volúmenes para listar los ficheros y las categorías de datos; 3) Marta prepara la notificación a la AEPD por fases: una inicial con lo conocido en las primeras 72 h y una completa después; 4) valoramos la comunicación a los clientes si se confirma alto riesgo; 5) preservamos todas las evidencias, porque pueden servir para una denuncia; 6) avisamos a la aseguradora y contactamos con INCIBE-CERT.

**Elena (comunicación):** ¿Avisamos ya a los clientes?

**Responsable:** Aún no con detalles: sin hechos confirmados informaríamos mal. Pero dejamos preparado el mensaje y las preguntas frecuentes para enviarlo en cuanto Marta lo valide. Nadie habla con los medios ni con clientes por su cuenta.


### Giro 3: el atacante mantiene acceso a la infraestructura

**Laura:** Seguimos viendo conexiones cada 60 segundos a 198.51.100.23, una IP distinta, desde un servidor: SRV-FICHEROS. Hay una tarea programada nueva creada a las 11:12 y una cuenta local creada. El atacante sigue dentro.

**Pablo:** Puedo apagar el servidor ahora mismo.

**Responsable:** No lo apagues todavía: primero volcamos memoria y hacemos imagen, o perderemos pruebas. Decisiones: 1) aislar SRV-FICHEROS de Internet y de la red de usuarios (mantener un acceso controlado para análisis); 2) bloquear 198.51.100.23 y todos los IOC nuevos; 3) restablecer las credenciales privilegiadas y las cuentas de servicio y, si hay indicios de compromiso del dominio, krbtgt dos veces; 4) buscar persistencia en todos los servidores (tareas, servicios, WMI, cuentas); 5) planificar una **erradicación coordinada** en una ventana corta, a la vez en todos los sistemas comprometidos, para que el atacante no reaccione; 6) como la infraestructura puede estar comprometida a un nivel que no controlamos del todo, pedimos apoyo a INCIBE-CERT y valoramos contratar una empresa forense externa.


### Giro 4: la dirección pide recuperar los servicios inmediatamente

**Director:** Llevamos medio día sin acceso a ficheros y los clientes llaman. Necesito todo funcionando esta tarde.

**Responsable:** Entiendo la presión. Te propongo tres opciones: (A) restaurar ya todo: la rechazo, porque con el atacante dentro volveríamos a exponer los datos y perderíamos más; (B) **recuperación escalonada por prioridad**: la recomiendo; (C) esperar a tener todo perfecto: demasiado lento para el negocio. Plan B: hoy, correo y atención al cliente en un entorno limpio y con MFA; mañana, el servidor de ficheros reconstruido desde imagen limpia con datos de una copia anterior a las 09:00, verificada con hash y analizada; después, el resto de sistemas. Cada paso, tras confirmar que no hay IOC.

**Director:** ¿Y mientras tanto?

**Responsable:** Continuidad temporal: trabajo con copias de los documentos imprescindibles en un entorno aislado, atención telefónica con procedimiento manual y un comunicado a clientes sobre «incidencia técnica». Lo que no haremos es reconectar sistemas sin verificar. Una recuperación apresurada con el atacante dentro costaría más: sanción de la AEPD, pérdida de confianza y más tiempo de parada.

**Director:** De acuerdo, aprobado el plan escalonado. ¿Qué necesitas?

**Responsable:** Presupuesto para el apoyo forense externo, autorización para el horario de erradicación y que RR. HH. y Comunicación cubran los mensajes. Próxima reunión a las 17:00.


## 6.3 Decisiones y justificación

| Situación | Decisión | Justificación |
|---|---|---|
| Otro equipo infectado | Aislar, buscar IOC en toda la flota, revisar movimiento lateral, elevar a crítica | El alcance es mayor del conocido; hay que ampliar la contención antes de erradicar. |
| Indicios de extracción | Asumir fuga probable, fijar hora de conocimiento, preparar AEPD por fases, DPO, preservar evidencias | RGPD art. 33 (72 h) y art. 34; el principio de precaución y la responsabilidad proactiva obligan a actuar sin esperar certeza total. |
| Atacante sigue dentro | No apagar el servidor antes de volcar la memoria; aislar, bloquear IOC, rotar credenciales, erradicación coordinada, apoyo externo | Evita perder pruebas y que el atacante cambie de táctica; la erradicación parcial alerta al atacante. |
| Presión para recuperar ya | Recuperación escalonada desde copias limpias con verificación | Equilibra continuidad y seguridad; reducir el riesgo de reinfección y de sanción. |

> [!TIP]
> **Para la defensa oral**
> Tendrás que justificar por qué se prioriza contener antes de erradicar, por qué no se apaga un equipo comprometido, cómo se decide la notificación a la AEPD, qué parte de la restauración es no negociable (verificar que la copia es anterior al compromiso) y cómo se comunica a la dirección una decisión impopular.


---

# 7. Herramientas utilizadas y resultados obtenidos

Resumen de las herramientas empleadas en las pruebas de laboratorio y de los resultados que se documentan con las capturas.

| Herramienta | Máquina | Uso | Resultado obtenido | Captura |
|---|---|---|---|---|
| OpenSSL | VM-KALI | Cifrado AES, RSA, firma y verificación | Datos cifrados y recuperados; firma válida y firma inválida tras modificar el archivo | 1.1 a 1.3 |
| Navegador (certificados) | ANFITRIÓN | Cadena de certificación de un sitio | Jerarquía servidor, CA intermedia y raíz | 1.4 |
| Python | VM-KALI | Diffie-Hellman con números pequeños | Mismo secreto compartido (2) en ambas partes | 1.5 |
| Microsoft Defender | VM-WIN | Detección de EICAR; reglas ASR; escaneo | Detección en cuarentena, eventos 1116/1117, ASR activas | 2.1, 2.2, 4.5, 4.7 |
| Visor de eventos / PowerShell | VM-WIN | Revisión de logs de seguridad | Eventos 4625/4624 localizados | 2.4 |
| Firewall de Windows (log) | VM-WIN | Registro de conexiones, regla de bloqueo | Conexiones periódicas registradas; regla de bloqueo aplicada | 2.3, 4.2 |
| Python http.server, tcpdump, Wireshark | VM-KALI | Servidor de pruebas y captura de tráfico | Patrón de beaconing cada ~10 s | 2.5, 3.7 |
| VirusTotal, AbuseIPDB | ANFITRIÓN | OSINT de IP, dominios y hashes | Reputación, país, ASN, detecciones | 2.6, 2.7, 3.5 |
| whois, dig | VM-KALI | Registro y resolución de un dominio | Fecha de creación, registrador, DNS e IP | 2.8 |
| grep, MXToolbox | VM-KALI / ANFITRIÓN | Análisis de cabeceras del correo de ejemplo | Suplantación detectada (SPF/DKIM/DMARC en fallo) | 3.1, 3.2 |
| file, exiftool, strings, olevba | VM-KALI | Análisis estático del documento con macro | Tipo real, metadatos y macro AutoOpen detectada | 3.3, 3.4 |
| netstat, tasklist, TCPView | VM-WIN | Relación conexión-proceso | Conexión asociada a powershell.exe | 3.6 |
| sha256sum, Get-FileHash | VM-KALI / VM-WIN | Hash SHA-256 y efecto avalancha | Hashes iguales entre sistemas; distintos tras el cambio | 3.8, 3.9 |
| dd, FTK Imager | VM-KALI / VM-WIN | Imagen forense y volcado de memoria | Hash de origen y de copia idénticos | 3.10, 3.11 |
| PowerShell, schtasks, Autoruns | VM-WIN | Aislamiento, credenciales, persistencia | Equipo aislado, cuenta revocada, persistencia eliminada | 4.1, 4.3, 4.4, 4.5 |
| Hipervisor (instantáneas) | ANFITRIÓN | Recuperación a estado limpio | VM restaurada sin rastro de la simulación | 4.6 |

> [!WARNING]
> **Comprueba esta tabla antes de entregar**
> La columna «Resultado obtenido» recoge lo que debería salir si las pruebas se hacen como se describen. Si en tu laboratorio algo difiere (otra versión, otra IP, un error), corrige el texto para que refleje lo que realmente obtuviste y explica la diferencia.


---

# 8. Conclusiones

El caso de Soluciones Delta muestra que un incidente grave puede comenzar con un solo clic y que el impacto real depende de lo preparada que esté la organización. Las principales conclusiones del trabajo son:

1. **El factor humano es la primera línea de defensa y también el punto más débil.** El phishing es eficaz porque explota la urgencia y la confianza; la formación continua y los simulacros reducen el riesgo, pero deben acompañarse de controles técnicos (macros bloqueadas, filtrado de correo, MFA).
2. **Sin procedimiento no hay respuesta ordenada.** La falta de un plan formal retrasa la detección, desordena las decisiones y pone en riesgo las evidencias y los plazos legales. Disponer de roles, plantillas y un árbol de decisión es la mejora de mayor retorno.
3. **Contener antes de erradicar y preservar antes de limpiar.** Aislar sin apagar, volcar la memoria y trabajar sobre copias con hash garantiza el valor probatorio y permite entender el alcance real.
4. **La brecha de datos personales es un asunto legal además de técnico.** El RGPD impone plazos (72 h) y obligaciones; el DPO y la dirección deben implicarse desde el primer momento y la decisión de notificar debe estar justificada y documentada.
5. **La recuperación debe ser segura, no solo rápida.** Restaurar desde copias limpias y de forma escalonada evita la reinfección y las consecuencias de una prisa mal gestionada.
6. **La ciberresiliencia es un ciclo:** anticipar, resistir, recuperar y evolucionar. Cada incidente es una oportunidad para mejorar el plan, la formación y la tecnología.
7. **La colaboración con los CSIRT** (INCIBE-CERT, CCN-CERT) aporta inteligencia, apoyo técnico y coordinación que una pyme no puede tener por sí sola.


### Valoración del trabajo práctico

Las pruebas en un laboratorio controlado han permitido comprobar de forma práctica cómo se ven en los registros un antivirus que detecta, un patrón de conexión periódica, una persistencia, un hash que cambia con un solo carácter o una firma que falla al modificar un archivo. Todas las pruebas se han hecho con ficheros inofensivos y en máquinas propias. **[Añade aquí tus dificultades, aprendizajes y qué mejorarías, en 4-6 líneas, con tu propia voz.]**


---

# 9. Fuentes consultadas


### Normativa y guías oficiales

- Reglamento (UE) 2016/679 (RGPD), en especial los artículos 4.12, 33 y 34. Diario Oficial de la UE.
- Ley Orgánica 3/2018, de Protección de Datos Personales y garantía de los derechos digitales (LOPDGDD).
- Agencia Española de Protección de Datos (AEPD): guía para la gestión y notificación de brechas de datos personales y sede electrónica. aepd.es
- Guía Nacional de Notificación y Gestión de Ciberincidentes (Consejo Nacional de Ciberseguridad; INCIBE, CCN-CERT y otros). 
- Real Decreto 311/2022, Esquema Nacional de Seguridad (ENS).
- Directiva (UE) 2022/2555 (NIS2): consultar el estado de su transposición en España.


### Estándares y marcos técnicos

- NIST SP 800-61, Computer Security Incident Handling Guide.
- NIST SP 800-160 Vol. 2, Developing Cyber-Resilient Systems.
- ISO/IEC 27035, gestión de incidentes de seguridad de la información; ISO/IEC 27001 y 27002.
- RFC 3227, Guidelines for Evidence Collection and Archiving (orden de volatilidad).
- MITRE ATT&CK: attack.mitre.org (técnicas T1566.001, T1204.002, T1071, T1083, T1021.002, T1041).
- RFC 5246 / RFC 8446 (TLS) y RFC 5280 (certificados X.509 y PKI); Diffie, W. y Hellman, M. (1976), New Directions in Cryptography.


### Organismos y herramientas consultadas

- INCIBE e INCIBE-CERT: incibe.es. Línea de ayuda en ciberseguridad: 017.
- CCN-CERT: ccn-cert.cni.es (guías CCN-STIC).
- CERT-EU: cert.europa.eu. ENISA: enisa.europa.eu. FIRST: first.org. CISA: cisa.gov.
- OpenSSL, Wireshark, Sysinternals (Sysmon, Autoruns, TCPView), FTK Imager, oletools, Kali Linux: documentación oficial de cada proyecto.
- VirusTotal, AbuseIPDB, MXToolbox, urlscan.io, abuse.ch (Feodo Tracker, URLhaus): servicios web de OSINT.
- **[Fecha de consulta: añade la fecha en que visitaste cada web.]**


---

# Anexo A. Correo de ejemplo para la práctica (phishing_sample.eml)

Crea este fichero en VM-KALI con un editor (`nano phishing_sample.eml`) y pega el contenido. Es completamente ficticio: los dominios y las IP son de documentación y no existen. El adjunto no se incluye (solo se menciona), por lo que el correo es inofensivo.

```text
Return-Path: <noreply@mailer-xyz.example>
Received: from mail.mailer-xyz.example (mail.mailer-xyz.example [203.0.113.45])
        by mx.solucionesdelta.example with ESMTP; Mon, 16 Nov 2026 09:12:03 +0100
Authentication-Results: mx.solucionesdelta.example;
        spf=fail smtp.mailfrom=mailer-xyz.example;
        dkim=none; dmarc=fail header.from=solucionesdelta.example
X-Originating-IP: 203.0.113.45
From: "Recursos Humanos" <rrhh@solucionesdelta.example>
Reply-To: rrhh.nominas@rrhh-solucionesdelta.example
To: empleado@solucionesdelta.example
Subject: Actualizacion de nomina - ACCION REQUERIDA
Date: Mon, 16 Nov 2026 09:11:58 +0100
Message-ID: <20261116091158.A1B2C3@mailer-xyz.example>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8

Estimado empleado:

Se ha actualizado su nomina de noviembre. Debe revisar el documento adjunto
(Nomina_Noviembre_2026.docm) y habilitar el contenido antes de las 14:00 de hoy,
o su pago podria retrasarse.

Descarguelo tambien aqui: http://rrhh-solucionesdelta.example/nomina

Departamento de Recursos Humanos
```


---

# Anexo B. Lista de comprobación de capturas (borrar antes de entregar)

Marca cada captura cuando la tengas hecha. Cada captura debe incluir la hora y, si se puede, el nombre de la máquina. Las marcadas como opcionales suben nota pero no son imprescindibles.

| Hecha | ID | Captura | Máquina | Opc. |
|---|---|---|---|---|
| [   ] | 1.1 | Cifrado simétrico AES-256 con OpenSSL | VM-KALI |  |
| [   ] | 1.2 | Par de claves RSA y cifrado asimétrico | VM-KALI |  |
| [   ] | 1.3 | Firma digital: verificación correcta y verificación fallida tras modificar el archivo | VM-KALI |  |
| [   ] | 1.4 | Cadena de certificación de un sitio web | ANFITRIÓN |  |
| [   ] | 1.5 | Intercambio de claves Diffie-Hellman con números pequeños | VM-KALI |  |
| [   ] | 2.1 | Detección del antivirus: historial de protección | VM-WIN |  |
| [   ] | 2.2 | Evento de Defender en el Visor de eventos (ID 1116/1117) | VM-WIN |  |
| [   ] | 2.3 | Registro del firewall de Windows (pfirewall.log) | VM-WIN |  |
| [   ] | 2.4 | Registros del sistema operativo: inicios de sesión (4624/4625) | VM-WIN |  |
| [   ] | 2.5 | Tráfico de red: peticiones periódicas en el servidor y en Wireshark | VM-KALI  |  |
| [   ] | 2.6 | Consulta de reputación de IP en VirusTotal | ANFITRIÓN |  |
| [   ] | 2.7 | Consulta de la misma IP en AbuseIPDB | ANFITRIÓN |  |
| [   ] | 2.8 | whois y dig/nslookup sobre un dominio | VM-KALI |  |
| [   ] | 3.1 | Análisis de cabeceras del correo con la línea de comandos | VM-KALI |  |
| [   ] | 3.2 | Análisis de cabeceras con MXToolbox Email Header Analyzer | ANFITRIÓN |  |
| [   ] | 3.3 | Análisis estático del documento con macros (file, hash, exiftool) | VM-KALI |  |
| [   ] | 3.4 | Análisis de macros con olevba | VM-KALI |  |
| [   ] | 3.5 | Consulta del hash de EICAR en VirusTotal (búsqueda por hash) | ANFITRIÓN |  |
| [   ] | 3.6 | Relación conexión-proceso en el equipo (netstat/TCPView) | VM-WIN |  |
| [   ] | 3.7 | Análisis de periodicidad y conversaciones en Wireshark | VM-KALI |  |
| [   ] | 3.8 | SHA-256 en Linux y efecto avalancha | VM-KALI |  |
| [   ] | 3.9 | SHA-256 en Windows: coincidencia con el hash de Linux | VM-WIN |  |
| [   ] | 3.10 | Adquisición de una imagen forense y verificación del hash | VM-KALI |  |
| [   ] | 3.11 | Volcado de memoria RAM del equipo (FTK Imager) | VM-WIN  | Sí |
| [   ] | 4.1 | Aislamiento del equipo infectado | VM-WIN |  |
| [   ] | 4.2 | Bloqueo de la IP maliciosa en el firewall | VM-WIN  |  |
| [   ] | 4.3 | Revocación de credenciales comprometidas | VM-WIN |  |
| [   ] | 4.4 | Detección de la persistencia (Autoruns o schtasks) | VM-WIN |  |
| [   ] | 4.5 | Eliminación de la persistencia y análisis de Defender | VM-WIN |  |
| [   ] | 4.6 | Restauración de VM-WIN al estado limpio | ANFITRIÓN  |  |
| [   ] | 4.7 | Reglas ASR de Defender habilitadas | VM-WIN |  |
| [   ] | 5.1 | Web de INCIBE-CERT: notificación de incidentes y línea de ayuda 017 | ANFITRIÓN |  |
| [   ] | 5.2 | Web del CCN-CERT | ANFITRIÓN |  |
| [   ] | 5.3 | Notificación de brechas en la sede electrónica de la AEPD | ANFITRIÓN |  |
| [   ] | 5.4 | Web de CERT-EU (equipo internacional de referencia) | ANFITRIÓN |  |

> [!TIP]
> **Cómo terminar el documento**
> Pega cada captura en el hueco de su recuadro ámbar y borra este anexo. También debes completar los campos entre corchetes: tu nombre, el SHA-256 real, las fechas de consulta y tu valoración personal.
