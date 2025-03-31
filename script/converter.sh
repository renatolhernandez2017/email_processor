#!/bin/sh
NOW=$(date +"%d-%m-%y")
WORK_DIR="/workspaces/unipharmus_v2/"
LOG_FILE="$WORK_DIR/tmp/log-$NOW.log"
TMP_DIR="$WORK_DIR/tmp/"

echo "O fechamento acabou de ser iniciado e está em andamento, não execute tarefas no sistema enquanto não receber o email com o log gerado!"

# echo "**** $(date) **** FAZENDO BACKUP DO BANCO DE DADOS DBFS ****" > $LOG_FILE
# mysqldump -u root -pYOH2mLwso7m dbfs bancos conta_correntes descontos fechamentos log_conversoes pessoas relatorio_mensais requisicoes schema_info usuarios > "$WORK_DIR/tmp/dbfs-$NOW.sql"
# cp -f "$WORK_DIR/tmp/dbfs-$NOW.sql" "$TMP_DIR/dbfs.sql" >> $LOG_FILE 2>> $LOG_FILE

# echo "**** $(date) **** REMOVENDO BASE PASSADA **** " >> $LOG_FILE
# # rm -Rf "$TMP_DIR/alterdb.ib"  >> $LOG_FILE
# rm -Rf "$TMP_DIR/*.sql" >> $LOG_FILE
# rm -Rf "$TMP_DIR/*.csv" >> $LOG_FILE

# echo "**** $(date) **** COPIANDO ARQUIVO DE BANCO DE DADOS **** " >> $LOG_FILE
#mount -t smbfs //192.168.0.5/FCerta /mnt/alternate -o username=rodrigo,password=jampers2 >> $LOG_FILE 2>> $LOG_FILE
#cp /mnt/alternate/DB/alterdb.ib "$TMP_DIR/alterdb.ib" >> $LOG_FILE 2>> $LOG_FILE
#umount /mnt/alternate >> $LOG_FILE 2>> $LOG_FILE
# net use x: /delete >> $LOG_FILE
# net use x: \\server04\FCerta >> $LOG_FILE
# copy x:\db\alterdb.ib d:\alternate\ >> $LOG_FILE

echo "**** $(date) **** CRIANDO ARQUIVOS CSV **** " >> $LOG_FILE
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey -i "$WORK_DIR/script/gera_csv_fc12100.sql" > "$TMP_DIR/fc12100.csv"  2>> $LOG_FILE
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey -i "$WORK_DIR/script/gera_csv_fc17000.sql" > "$TMP_DIR/fc17000.csv"  2>> $LOG_FILE
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey -i "$WORK_DIR/script/gera_csv_fc04000.sql" > "$TMP_DIR/fc04000.csv"  2>> $LOG_FILE
isql-fb "192.168.0.11:d:\\fcerta\\db\\alterdb.ib" -u sysdba -p masterkey -i "$WORK_DIR/script/gera_csv_fc17100.sql" > "$TMP_DIR/fc17100.csv"  2>> $LOG_FILE

# echo "**** $(date) **** CONVERTENDO CSV PARA IB.SQL **** " >> $LOG_FILE
# ruby "$WORK_DIR/script/gera_ib_sql.rb" >> $LOG_FILE 2>> $LOG_FILE

# echo "**** $(date) **** CRIANdO ESTRUTURA DA BASE DE DADOS **** " >> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$WORK_DIR/db/estrutura_fc.sql" 2>> $LOG_FILE

# echo "**** $(date) **** INSERINDO IB.SQL PARA MYSQL **** " >> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$TMP_DIR/ps0120.sql" 2>> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$TMP_DIR/ps0170.sql" 2>> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$TMP_DIR/ps0040.sql" 2>> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$TMP_DIR/fc17100.sql" 2>> $LOG_FILE

# echo "**** $(date) **** CONVERTENDO DADOS PARA FECHAMENTO **** " >> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$WORK_DIR/db/conversao_diaria.sql" 2>> $LOG_FILE
# mysql -u root -pYOH2mLwso7m dbfs < "$WORK_DIR/db/altera_valores_para_relatorio.sql" 2>> $LOG_FILE
# ruby "$WORK_DIR/script/runner" -e production "Fechamento.deste_mes.efetua_fechamento" 2>> $LOG_FILE

# echo "**** $(date) **** FINALIZANDO **** " >> $LOG_FILE
# cp $LOG_FILE "$TMP_DIR/conv_fc.log"  2>> $LOG_FILE
# #ruby "$WORK_DIR/script/runner" -e production ResultadoDoFechamento.deliver_fechamento 2>> $LOG_FILE
# echo "Log do fechamento, segue arquivo de log em anexo." |  mutt -s "Log do fechamento" hugo.borges@gmail.com -c robson@unipharmus.com.br -a $LOG_FILE

echo "**** $(date) **** ACABOU **** " >> $LOG_FILE
