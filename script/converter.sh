#!/bin/sh
set -e

NOW=$(date +"%d-%m-%y")
WORK_DIR="/workspaces/unipharmus_v2"
LOG_FILE="$WORK_DIR/tmp/log-$NOW.log"
TMP_DIR="$WORK_DIR/tmp/"

START_DATE=$1
END_DATE=$2

export START_DATE
export END_DATE

echo "Data Inicio: $START_DATE"
echo "Data Final: $END_DATE"

echo "Abre a conexão com a VPN"
echo "Abre a conexão com a VPN" >> $LOG_FILE
/bin/bash /workspaces/unipharmus_v2/script/vpn_start.sh

echo "Agora conecta ao banco via Firebird"
echo "Agora conecta ao banco via Firebird" >> $LOG_FILE
echo "**** $(date) **** CRIANDO ARQUIVOS CSV **** " >> $LOG_FILE

echo "Criando arquivo das Filial"
echo "Criando arquivo das Filial" >> $LOG_FILE
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc01000.sql" > "$TMP_DIR/fc01000.csv" 2>> $LOG_FILE
sleep 2

echo "Criando arquivo dos Representante"
echo "Criando arquivo dos Representante" >> $LOG_FILE
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc08000.sql" > "$TMP_DIR/fc08000.csv" 2>> $LOG_FILE
sleep 2

echo "Criando arquivo Prescritores e Requisições"
echo "Criando arquivo Prescritores e Requisições" >> $LOG_FILE
envsubst < "$WORK_DIR/script/all.sql" | \
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey > "$TMP_DIR/all.csv" 2>> $LOG_FILE
sleep 2

echo "Fecha a conexão com a VPN"
echo "Fecha a conexão com a VPN" >> $LOG_FILE
/bin/bash /workspaces/unipharmus_v2/script/vpn_close.sh

echo "ACABOU"
echo "**** $(date) **** ACABOU **** " >> $LOG_FILE

exit 0
