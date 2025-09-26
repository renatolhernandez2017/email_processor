#!/bin/bash

# Para fechar a conexão OpenVPN, encontre o PID e mate o processo:

# Modo com sudo só funciona com devContainer direto no Vscode
# sudo pkill -f "openvpn --config /workspaces/unipharmus_v2/script/OpenVPN_devel01.ovpn"

# Modo sem sudo só funciona com os dockers direto no Terminal
pkill -f "openvpn --config /workspaces/unipharmus_v2/script/OpenVPN_devel01.ovpn"
