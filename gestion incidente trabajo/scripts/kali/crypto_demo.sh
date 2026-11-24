#!/usr/bin/env bash
# Demostración de criptografía aplicada (apartado 1.5 del informe).
# Ejecutar en VM-KALI. Genera ficheros de prueba en ~/cripto (o en la carpeta indicada).
# Uso: ./crypto_demo.sh [carpeta_de_trabajo]
set -euo pipefail

WORK="${1:-$HOME/cripto}"
PASS="clave-de-laboratorio"   # SOLO para la demo; en las capturas la contraseña se escribió a mano
mkdir -p "$WORK" && cd "$WORK"
echo "Datos confidenciales del cliente 0001" > secreto.txt

echo "== 1.1 Cifrado simétrico AES-256-CBC =="
openssl enc -aes-256-cbc -pbkdf2 -salt -pass pass:"$PASS" -in secreto.txt -out secreto.enc
head -c 120 secreto.enc | xxd                      # contenido ilegible
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASS" -in secreto.enc -out secreto_dec.txt
cat secreto_dec.txt

echo "== 1.2 Cifrado asimétrico RSA-2048 =="
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out priv.pem
openssl pkey -in priv.pem -pubout -out pub.pem
openssl pkeyutl -encrypt -pubin -inkey pub.pem -in secreto.txt -out secreto.rsa
openssl pkeyutl -decrypt -inkey priv.pem -in secreto.rsa
ls -l priv.pem pub.pem secreto.rsa

echo "== 1.3 Firma digital =="
openssl dgst -sha256 -sign priv.pem -out firma.bin secreto.txt
openssl dgst -sha256 -verify pub.pem -signature firma.bin secreto.txt      # Verified OK
echo "x" >> secreto.txt
openssl dgst -sha256 -verify pub.pem -signature firma.bin secreto.txt || true   # Verification failure

echo "== 1.4 Cadena de certificación (sitio real, solo lectura) =="
openssl s_client -connect www.incibe.es:443 -showcerts </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates

echo "== 1.5 Diffie-Hellman con números pequeños (didáctico) =="
python3 -c "p=23;g=5;a=6;b=15;A=pow(g,a,p);B=pow(g,b,p);print('A=',A,'B=',B,'secreto Alicia=',pow(B,a,p),'secreto Beto=',pow(A,b,p))"

date; hostname
