#!/bin/bash
sudo openvpn --config /workspaces/unipharmus_v2/public/OpenVPN_devel01.ovpn --daemon

# Aguarda a VPN subir (ajuste conforme necessário)
sleep 10
