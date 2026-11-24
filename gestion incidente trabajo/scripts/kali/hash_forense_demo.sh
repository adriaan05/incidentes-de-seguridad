#!/usr/bin/env bash
# Hash SHA-256, efecto avalancha e imagen forense con dd (apartados 3.6 y 3.7 del informe).
# Ejecutar en VM-KALI. Requiere sudo para montar el disco de pruebas.
# Uso: ./hash_forense_demo.sh [carpeta_de_trabajo]
set -euo pipefail

WORK="${1:-$HOME/forense}"
mkdir -p "$WORK" && cd "$WORK"

echo "== Hash SHA-256 y efecto avalancha =="
echo "Evidencia 001 - informe de prueba" > evidencia.txt
cp evidencia.txt evidencia_original.txt      # copia para calcular su hash también en Windows
sha256sum evidencia.txt
echo "." >> evidencia.txt                      # cambiar un único carácter
sha256sum evidencia.txt                        # el hash cambia por completo

echo "== Imagen forense de un disco de pruebas =="
dd if=/dev/zero of=disco_pruebas.img bs=1M count=50
mkfs.ext4 -q disco_pruebas.img
mkdir -p mnt && sudo mount -o loop disco_pruebas.img mnt
echo "dato del cliente" | sudo tee mnt/cliente.txt >/dev/null && sudo umount mnt
sha256sum disco_pruebas.img | tee hash_origen.txt
dd if=disco_pruebas.img of=imagen_forense.img bs=4M status=progress
sha256sum imagen_forense.img | tee hash_copia.txt
chmod 444 imagen_forense.img                   # solo lectura
echo "--- Comparación de hashes (deben coincidir) ---"
cat hash_origen.txt hash_copia.txt

date; hostname
