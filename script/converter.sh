#!/bin/sh
set -e

NOW=$(date +"%d-%m-%y")
# WORK_DIR="/workspaces/unipharmus_v2"
WORK_DIR="/rails"
LOG_FILE="$WORK_DIR/tmp/log-$NOW.log"
TMP_DIR="$WORK_DIR/tmp/"

mkdir -p "$TMP_DIR"

START_DATE=$1
END_DATE=$2

export START_DATE
export END_DATE

echo "Data Inicio: $START_DATE"
echo "Data Final: $END_DATE"

echo "**** $(date) **** CRIANDO ARQUIVOS CSV **** " >> $LOG_FILE

echo "Criando arquivo das Filiais"
echo "Criando arquivo das Filiais" >> $LOG_FILE
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc01000.sql" > "$TMP_DIR/fc01000.csv" 2>> $LOG_FILE

echo "Criando arquivo dos Representantes"
echo "Criando arquivo dos Representantes" >> $LOG_FILE
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc08000.sql" > "$TMP_DIR/fc08000.csv" 2>> $LOG_FILE

echo "Criando arquivo Prescritores e Requisições"
echo "Criando arquivo Prescritores e Requisições" >> $LOG_FILE
envsubst < "$WORK_DIR/script/all.sql" | \
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey > "$TMP_DIR/all.csv" 2>> $LOG_FILE

echo "ACABOU"
echo "**** $(date) **** ACABOU **** " >> $LOG_FILE

exit 0
