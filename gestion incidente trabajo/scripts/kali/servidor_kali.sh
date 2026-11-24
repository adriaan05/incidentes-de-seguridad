#!/usr/bin/env bash
# Servidor de pruebas que simula la IP del atacante (apartado 2.4, práctica A).
# Sirve HTTP en el puerto 8000 y captura el tráfico de la víctima en ~/beacon.pcap.
# Uso: ./servidor_kali.sh <interfaz> <ip_victima>
# Ejemplo: ./servidor_kali.sh eth0 192.168.68.102
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Uso: $0 <interfaz> <ip_victima>   (ej.: $0 eth0 192.168.68.102)" >&2
  exit 1
fi
IFACE="$1"; VICTIMA="$2"
PCAP="$HOME/beacon.pcap"

mkdir -p "$HOME/servidor" && cd "$HOME/servidor"

sudo tcpdump -i "$IFACE" host "$VICTIMA" -w "$PCAP" &
TCPDUMP_PID=$!
trap 'sudo kill "$TCPDUMP_PID" 2>/dev/null || true; echo "Captura guardada en $PCAP"' EXIT

echo "Servidor en el puerto 8000. Captura en $PCAP. Ctrl+C para parar."
python3 -m http.server 8000
