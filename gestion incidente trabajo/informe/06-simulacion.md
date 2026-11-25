# 6. Simulación: reunión del equipo de respuesta a incidentes

## 6.1 Participantes y reglas

| **Rol** | **Persona (ficticia)** | **Responsabilidad en la reunión** |
|---|---|---|
| Responsable de ciberseguridad (modera) | Adrián Fuente | Dirige, prioriza y justifica las decisiones técnicas |
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

**Responsable:** Decisiones: 1) consideramos la fuga **probable** y fijamos la hora de conocimiento en este momento, por lo que el límite de 72 h es las 12:40 del 19/11/2026; 2) Laura cruza los 5145 con los volúmenes para listar los ficheros y las categorías de datos; 3) Marta prepara la notificación a la AEPD por fases: una inicial con lo conocido en las primeras 72 h y una completa después; 4) valoramos la comunicación a los clientes si se confirma alto riesgo; 5) preservamos todas las evidencias, porque pueden servir para una denuncia; 6) avisamos a la aseguradora y contactamos con INCIBE-CERT.

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

| **Situación** | **Decisión** | **Justificación** |
|---|---|---|
| Otro equipo infectado | Aislar, buscar IOC en toda la flota, revisar movimiento lateral, elevar a crítica | El alcance es mayor del conocido; hay que ampliar la contención antes de erradicar. |
| Indicios de extracción | Asumir fuga probable, fijar hora de conocimiento, preparar AEPD por fases, DPO, preservar evidencias | RGPD art. 33 (72 h) y art. 34; el principio de precaución y la responsabilidad proactiva obligan a actuar sin esperar certeza total. |
| Atacante sigue dentro | No apagar el servidor antes de volcar la memoria; aislar, bloquear IOC, rotar credenciales, erradicación coordinada, apoyo externo | Evita perder pruebas y que el atacante cambie de táctica; la erradicación parcial alerta al atacante. |
| Presión para recuperar ya | Recuperación escalonada desde copias limpias con verificación | Equilibra continuidad y seguridad; reducir el riesgo de reinfección y de sanción. |

> **Puntos que defenderé en la exposición oral**
>
> Justificaré por qué se prioriza contener antes de erradicar, por qué no se apaga un equipo comprometido, cómo se decide la notificación a la AEPD, qué parte de la restauración es no negociable (verificar que la copia es anterior al compromiso) y cómo se comunica a la dirección una decisión impopular.
