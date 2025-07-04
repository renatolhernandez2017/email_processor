#!/bin/sh
set -e
set -x

NOW=$(date +"%d-%m-%y")
# WORK_DIR="/workspaces/unipharmus_v2"
WORK_DIR="/rails"
TMP_DIR="$WORK_DIR/tmp/"

START_DATE=$1
END_DATE=$2

export START_DATE
export END_DATE

echo "Data Inicio: $START_DATE"
echo "Data Final: $END_DATE"

echo "Criando arquivo das Filiais"
isql-fb "/mnt/db/alterdb.ibui " -u sysdba -p masterkey < "$WORK_DIR/script/fc01000.sql" > "$TMP_DIR/fc01000.csv"

echo "Criando arquivo dos Representantes"
isql-fb "/mnt/db/alterdb.ibui " -u sysdba -p masterkey < "$WORK_DIR/script/fc08000.sql" > "$TMP_DIR/fc08000.csv"

echo "Criando arquivo Prescritores e Requisições"
envsubst < "$WORK_DIR/script/all.sql" | \
isql-fb "/mnt/db/alterdb.ibui " -u sysdba -p masterkey > "$TMP_DIR/all.csv"

echo "ACABOU"

exit 0
