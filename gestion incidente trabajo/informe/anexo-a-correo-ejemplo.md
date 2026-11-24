# Anexo A. Correo de ejemplo para la práctica (phishing_sample.eml)

Este fichero lo guardé en VM-KALI con un editor (nano phishing_sample.eml). Es completamente ficticio: los dominios y las IP son de documentación y no existen. El adjunto no se incluye (solo se menciona), por lo que el correo es inofensivo.

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
