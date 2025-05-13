#!/bin/bash

# Para fechar a conexão OpenVPN, encontre o PID e mate o processo:
sudo pkill -f "openvpn --config /workspaces/unipharmus_v2/public/OpenVPN_devel01.ovpn"
