# 8. Conclusiones

El caso de Soluciones Delta muestra que un incidente grave puede comenzar con un solo clic y que el impacto real depende de lo preparada que esté la organización. Las principales conclusiones del trabajo son:

- **El factor humano es la primera línea de defensa y también el punto más débil.** El phishing es eficaz porque explota la urgencia y la confianza; la formación continua y los simulacros reducen el riesgo, pero deben acompañarse de controles técnicos (macros bloqueadas, filtrado de correo, MFA).
- **Sin procedimiento no hay respuesta ordenada.** La falta de un plan formal retrasa la detección, desordena las decisiones y pone en riesgo las evidencias y los plazos legales. Disponer de roles, plantillas y un árbol de decisión es la mejora de mayor retorno.
- **Contener antes de erradicar y preservar antes de limpiar.** Aislar sin apagar, volcar la memoria y trabajar sobre copias con hash garantiza el valor probatorio y permite entender el alcance real.
- **La brecha de datos personales es un asunto legal además de técnico.** El RGPD impone plazos (72 h) y obligaciones; el DPO y la dirección deben implicarse desde el primer momento y la decisión de notificar debe estar justificada y documentada.
- **La recuperación debe ser segura, no solo rápida.** Restaurar desde copias limpias y de forma escalonada evita la reinfección y las consecuencias de una prisa mal gestionada.
- **La ciberresiliencia es un ciclo:** anticipar, resistir, recuperar y evolucionar. Cada incidente es una oportunidad para mejorar el plan, la formación y la tecnología.
- **La colaboración con los CSIRT** (INCIBE-CERT, CCN-CERT) aporta inteligencia, apoyo técnico y coordinación que una pyme no puede tener por sí sola.

### Valoración del trabajo práctico

Las pruebas en un laboratorio controlado me han permitido comprobar de forma práctica cómo se ven en los registros un antivirus que detecta, un patrón de conexión periódica, una persistencia, un hash que cambia con un solo carácter o una firma que falla al modificar un archivo. Todas las pruebas se han hecho con ficheros inofensivos y en máquinas propias. Las dificultades fueron sobre todo técnicas: la licencia de evaluación de Windows Server caducó y la máquina se apagaba sola, por lo que repetí alguna prueba; una regla de firewall que dejé activa cortó la conexión con Kali hasta que la eliminé y reactivé el adaptador; varios bucles de beaconing lanzados a la vez generaron ráfagas de peticiones; y Get-NetTCPConnection no veía las conexiones, demasiado breves, por lo que usé una conexión mantenida. Tampoco pude crear un documento con macro (no tenía Word ni LibreOffice), hacer el volcado de memoria ni restaurar una instantánea previa. Si repitiera el trabajo, crearía instantáneas de ambas máquinas desde el principio, usaría un Windows con licencia estable e instalaría Sysmon para tener telemetría más detallada.
