#!/bin/sh
NOW=$(date +"%d-%m-%y")
WORK_DIR="/workspaces/unipharmus_v2"
LOG_FILE="$WORK_DIR/tmp/log-$NOW.log"
TMP_DIR="$WORK_DIR/tmp/"

START_DATE=$1
END_DATE=$2

echo "Data Inicio: $START_DATE"
echo "Data Final: $END_DATE"

echo "Abre a conexão com a VPN"
echo "Abre a conexão com a VPN" >> $LOG_FILE
/bin/bash /workspaces/unipharmus_v2/script/vpn_start.sh

# Agora conecta ao banco Firebird
# echo "O fechamento acabou de ser iniciado e está em andamento, não execute tarefas no sistema enquanto não receber o email com o log gerado!"
# echo "**** $(date) **** CRIANDO ARQUIVOS CSV **** " >> $LOG_FILE

# echo "Criando arquivo dos Representante" >> $LOG_FILE
# isql-fb "192.168.0.12:D:\\Fcerta-teste\\DB\\ALTERDB.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc08000.sql" > "$TMP_DIR/fc08000.csv" 2>> $LOG_FILE
# sleep 1

# echo "Criando arquivo das Filial" >> $LOG_FILE
# isql-fb "192.168.0.12:D:\\Fcerta-teste\\DB\\ALTERDB.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc01000.sql" > "$TMP_DIR/fc01000.csv" 2>> $LOG_FILE
# sleep 1

# echo "Criando arquivo dos Prescritores" >> $LOG_FILE
# isql-fb "192.168.0.12:D:\\Fcerta-teste\\DB\\ALTERDB.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc04000.sql" > "$TMP_DIR/fc04000.csv" 2>> $LOG_FILE
# sleep 1

# echo "Criando arquivo das Requisições" >> $LOG_FILE
# isql-fb "192.168.0.12:D:\\Fcerta-teste\\DB\\ALTERDB.ib" -u sysdba -p masterkey < "$WORK_DIR/script/fc12100_fc17000_fc17100.sql" > "$TMP_DIR/fc12100_fc17000_fc17100.csv" 2>> $LOG_FILE
# sleep 1

# echo "**** $(date) **** CONVERTENDO DADOS PARA FECHAMENTO **** " >> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$WORK_DIR/db/conversao_diaria.sql" 2>> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$WORK_DIR/db/altera_valores_para_relatorio.sql" 2>> $LOG_FILE
# ruby "$WORK_DIR/script/runner" -e production "Fechamento.deste_mes.efetua_fechamento" 2>> $LOG_FILE

echo "Fecha a conexão com a VPN"
echo "Fecha a conexão com a VPN" >> $LOG_FILE
/bin/bash /workspaces/unipharmus_v2/script/vpn_close.sh

echo "ACABOU"
echo "**** $(date) **** ACABOU **** " >> $LOG_FILE
