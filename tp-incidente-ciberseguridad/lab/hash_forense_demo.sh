#!/usr/bin/env bash
# Apartados 3.6 y 3.7 - SHA-256 y adquisición forense de un disco de pruebas (VM-KALI)
set -e
cd ~
echo "Evidencia 001 - informe de prueba" > evidencia.txt
cp evidencia.txt evidencia_original.txt      # copiar a VM-WIN para Get-FileHash (captura 3.9)
sha256sum evidencia.txt
echo "." >> evidencia.txt
sha256sum evidencia.txt                       # efecto avalancha (captura 3.8)

dd if=/dev/zero of=disco_pruebas.img bs=1M count=50
mkfs.ext4 -q disco_pruebas.img
mkdir -p mnt && sudo mount -o loop disco_pruebas.img mnt
echo "dato del cliente" | sudo tee mnt/cliente.txt
sudo umount mnt
sha256sum disco_pruebas.img | tee hash_origen.txt
dd if=disco_pruebas.img of=imagen_forense.img bs=4M status=progress
sha256sum imagen_forense.img | tee hash_copia.txt
chmod 444 imagen_forense.img
ls -l imagen_forense.img                      # captura 3.10
