#!/usr/bin/env bash
# Apartado 1.5 - Criptografía (VM-KALI). Solo material de prueba.
set -e
mkdir -p ~/cripto && cd ~/cripto
echo "Datos confidenciales del cliente 0001" > secreto.txt

echo "== Simétrico AES-256 (captura 1.1) =="
openssl enc -aes-256-cbc -pbkdf2 -salt -in secreto.txt -out secreto.enc
cat secreto.enc | head -c 120; echo
openssl enc -d -aes-256-cbc -pbkdf2 -in secreto.enc -out secreto_dec.txt
cat secreto_dec.txt

echo "== Asimétrico RSA (captura 1.2) =="
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out priv.pem
openssl pkey -in priv.pem -pubout -out pub.pem
openssl pkeyutl -encrypt -pubin -inkey pub.pem -in secreto.txt -out secreto.rsa
openssl pkeyutl -decrypt -inkey priv.pem -in secreto.rsa

echo "== Firma digital (captura 1.3) =="
openssl dgst -sha256 -sign priv.pem -out firma.bin secreto.txt
openssl dgst -sha256 -verify pub.pem -signature firma.bin secreto.txt
echo "x" >> secreto.txt
openssl dgst -sha256 -verify pub.pem -signature firma.bin secreto.txt || true

echo "== Diffie-Hellman (captura 1.5) =="
python3 -c "p=23;g=5;a=6;b=15;A=pow(g,a,p);B=pow(g,b,p);print('A=',A,'B=',B,'secreto Alicia=',pow(B,a,p),'secreto Beto=',pow(A,b,p))"
date; hostname
