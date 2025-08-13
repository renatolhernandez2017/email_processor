#!/bin/sh
set -e
set -x # isso mostra a execução de linha por linha no terminal

NOW=$(date +"%d-%m-%y")

if [ "$RAILS_ENV" = "development" ]; then
  WORK_DIR="/workspaces/unipharmus_v2"
else
  WORK_DIR="/rails"
fi

TMP_DIR="$WORK_DIR/tmp/"

START_DATE=$1
END_DATE=$2

export START_DATE
export END_DATE

echo "Data Inicio: $START_DATE"
echo "Data Final: $END_DATE"

if [ "$RAILS_ENV" = "development" ]; then
  echo "Abre a conexão com a VPN"
  /bin/bash /workspaces/unipharmus_v2/script/vpn_start.sh
fi

echo "Criando arquivo das Filiais"
if [ "$RAILS_ENV" = "development" ]; then
  isql-fb "192.168.0.12:D:\\Fcerta-teste\\DB\\ALTERDB.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc01000.sql" > "$TMP_DIR/fc01000.csv"
else
  isql-fb "192.168.0.10:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc01000.sql" > "$TMP_DIR/fc01000.csv"
fi

echo "Criando arquivo dos Representantes"
if [ "$RAILS_ENV" = "development" ]; then
  isql-fb "192.168.0.12:D:\\Fcerta-teste\\DB\\ALTERDB.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc08000.sql" > "$TMP_DIR/fc08000.csv"
else
  isql-fb "192.168.0.10:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc08000.sql" > "$TMP_DIR/fc08000.csv"
fi

echo "Criando arquivo Prescritores e Requisições"
envsubst < "$WORK_DIR/script/all.sql" | \
if [ "$RAILS_ENV" = "development" ]; then
  isql-fb "192.168.0.12:D:\\Fcerta-teste\\DB\\ALTERDB.ib" -u sysdba -p masterkey > "$TMP_DIR/all.csv"
else
  isql-fb "192.168.0.10:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey > "$TMP_DIR/all.csv"
fi

if [ "$RAILS_ENV" = "development" ]; then
  echo "Fecha a conexão com a VPN"
  /bin/bash /workspaces/unipharmus_v2/script/vpn_close.sh
fi

echo "ACABOU"

exit 0
