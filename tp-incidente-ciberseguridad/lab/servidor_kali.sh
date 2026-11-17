#!/usr/bin/env bash
# Apartados 2 y 3 - Servidor de pruebas que simula la IP del atacante (VM-KALI, 192.168.56.10)
# Ajusta la interfaz (ip a) y la IP de VM-WIN si son distintas.
IFACE=${1:-eth0}
VICTIMA=${2:-192.168.56.20}
mkdir -p ~/servidor && cd ~/servidor
sudo tcpdump -i "$IFACE" host "$VICTIMA" -w ~/beacon.pcap &
python3 -m http.server 8000
