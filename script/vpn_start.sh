#!/bin/bash

# Modo com sudo só funciona com devContainer direto no Vscode
# sudo openvpn --config /workspaces/unipharmus_v2/script/OpenVPN_devel01.ovpn --daemon

# Modo sem sudo só funciona com os dockers direto no Terminal
openvpn --config /workspaces/unipharmus_v2/script/OpenVPN_devel01.ovpn --daemon

# Aguarda a VPN subir (ajuste conforme necessário)
sleep 10
