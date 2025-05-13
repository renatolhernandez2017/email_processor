require 'rubygems'
require 'fastercsv'

ps0120 = File.open("/home/deploy/repos/saltopus_2/tmp/ps0120.sql", "w")
ps0120 << "DELETE FROM ps0120; \n"
ps0120 << "LOCK TABLES ps0120 WRITE; \n"
ps0120 << "ALTER TABLE ps0120 DISABLE KEYS; \n"
File.open("/home/deploy/repos/saltopus_2/tmp/fc12100.csv", 'r').each do |line|
  begin
      row = FasterCSV.parse_line(line)
      row[9] = '' if row[9].nil?
      ps0120 << "INSERT INTO ps0120 (CDFILO, NREQUI, SERIER, PRFCRM, UFDCRM, NROCRM, PRCOBR, VLDESC, VLACRE, NOMEPA, DTENTR, REPETIDA) values ('#{row[0].rjust(3)}', '#{row[1].rjust(6)}', '#{row[2]}', '#{row[3]}', '#{row[4]}', '#{row[5].rjust(6)[0..5]}', #{row[6]}, #{row[7]}, #{row[8]}, '#{row[9].gsub(/[,"';\\\/]/, ' ')}', '#{row[10]}', '#{row[11]}'); \n" unless row[1].nil?
  rescue FasterCSV::MalformedCSVError
    puts "Erro em " + line
  end
end
ps0120 << "ALTER TABLE ps0120 ENABLE KEYS; \n"
ps0120 << "UNLOCK TABLES; \n"

ps0170 = File.open("/home/deploy/repos/saltopus_2/tmp/ps0170.sql", "w")
ps0170 << "DELETE FROM ps0170; \n"
ps0170 << "LOCK TABLES ps0170 WRITE; \n"
ps0170 << "ALTER TABLE ps0170 DISABLE KEYS; \n"
FasterCSV.foreach("/home/deploy/repos/saltopus_2/tmp/fc17000.csv") do |row|
    row[0] = '' if row[0].nil?
    row[1] = '' if row[1].nil?
    row[4] = '' if row[4].nil?
    row[12] = '' if row[12].nil?
    unless row[6].nil?
      ps0170 << "INSERT INTO ps0170 (CDFIL, NRREQ, PFCRM, UFCRM, NRCRM, DTENT, DTPAG, TOTAL, DESCO, VLTXA, SALDO, RECEB, CDFILP, CDCON) values ('#{row[0].rjust(3)}', '#{row[1].rjust(6)}', '#{row[2]}', '#{row[3]}', '#{row[4].rjust(6)}', '#{row[5]}', '#{row[6]}', #{row[7]}, #{row[8]}, #{row[9]}, '#{row[10]}', #{row[11]}, '#{row[12].rjust(3)}', '#{row[13]}'); \n" unless row[1].empty?
    else
      ps0170 << "INSERT INTO ps0170 (CDFIL, NRREQ, PFCRM, UFCRM, NRCRM, DTENT, DTPAG, TOTAL, DESCO, VLTXA, SALDO, RECEB, CDFILP, CDCON) values ('#{row[0].rjust(3)}', '#{row[1].rjust(6)}', '#{row[2]}', '#{row[3]}', '#{row[4].rjust(6)}', '#{row[5]}', NULL, #{row[7]}, #{row[8]}, #{row[9]}, '#{row[10]}', #{row[11]}, '#{row[12].rjust(3)}', '#{row[13]}'); \n" unless row[1].empty?
    end
end
ps0170 << "ALTER TABLE ps0170 ENABLE KEYS; \n"
ps0170 << "UNLOCK TABLES; \n"

fc17100 = File.open("/home/deploy/repos/saltopus_2/tmp/fc17100.sql", "w")
fc17100 << "DELETE FROM fc17100; \n"
fc17100 << "LOCK TABLES fc17100 WRITE; \n"
fc17100 << "ALTER TABLE fc17100 DISABLE KEYS; \n"
FasterCSV.foreach("/home/deploy/repos/saltopus_2/tmp/fc17100.csv") do |row|
    row[0] = '' if row[0].nil?
    row[1] = '' if row[1].nil?
    row[2] = '' if row[2].nil?
    row[3] = '' if row[3].nil?
    fc17100 << "INSERT INTO fc17100 (CDFIL, NRREQ, DTPAG, TOTAL) values ('#{row[0].rjust(3)}', '#{row[1].rjust(6)}', '#{row[2]}', #{row[3]}); \n" unless row[1].empty?
end
fc17100 << "ALTER TABLE fc17100 ENABLE KEYS; \n"
fc17100 << "UNLOCK TABLES; \n"


ps0040 = File.open("/home/deploy/repos/saltopus_2/tmp/ps0040.sql", "w")
ps0040 << "DELETE FROM ps0040; \n"
ps0040 << "LOCK TABLES ps0040 WRITE; \n"
ps0040 << "ALTER TABLE ps0040 DISABLE KEYS; \n"
File.open("/home/deploy/repos/saltopus_2/tmp/fc04000.csv", 'r').each do |line|
  begin
    row = FasterCSV.parse_line(line)
    cdvst = row[5] ? row[5][0..2].rjust(3, "0") : "999"
    ender1 = row[6] ? row[6] : ""  
    ender2 = row[7] ? row[7] : ""  
    ender3 = row[8] ? row[8] : ""  
    ender = (ender1 + " " + ender2 + " " + ender3)[0..49].gsub(/[,"';\\\/]/, ' ')
    bairro = row[9] ? row[9][0..19].gsub(/[,"';\\\/]/, ' ') : ""
    munic = row[11] ? row[11][0..19].gsub(/[,"';\\\/]/, ' ') : ""
    cep = row[10] ? row[10][0..7].gsub(/[,"';\\\/]/, ' ') : ""
    nome = row[3] ? row[3][0..49].gsub(/[,"';\\\/]/, ' ') : "SN"
    obs = row[4] ? row[4][0..49].gsub(/[,"';\\\/]/, ' ') : " "
    ddd = row[13] ? row[13][0..3].gsub(/[,"';\\\/]/, ' ') : ""
    tel = row[14] ? row[14][0..7].gsub(/[,"';\\\/]/, ' ') : ""
    fax = row[18] ? row[18][0..7].gsub(/[,"';\\\/]/, ' ') : ""
    ddd1 = row[15] ? row[15][0..3].gsub(/[,"';\\\/]/, ' ') : ""
    tel1 = row[16] ? row[16][0..7].gsub(/[,"';\\\/]/, ' ') : ""
    fax1 = row[18] ? row[18][0..7].gsub(/[,"';\\\/]/, ' ') : ""
    ps0040 << "INSERT INTO ps0040 (PFCRM, UFCRM, NRCRM, NOMEM, OBSERV, CDVST, ENDER, NRCEP, BAIRR, MUNIC, UNFED, NRDDD, NRTEL, NRFAX, NRDDD1, NRTEL1, NRFAX1) values ('#{row[0].rjust(1)}', '#{row[1].rjust(2)}', '#{row[2].rjust(6)[0..5]}', '#{nome}', '#{obs}', '#{cdvst}', '#{ender}', '#{cep}', '#{bairro}', '#{munic}', '#{row[12]}', '#{ddd}', '#{tel}', '#{fax}', '#{ddd1}', '#{tel1}', '#{fax1}' ); \n".gsub(/[\/]/, ' ') if row[1]
  rescue FasterCSV::MalformedCSVError
    puts "Erro em " + line
  end
end
ps0040 << "ALTER TABLE ps0040 ENABLE KEYS; \n"
ps0040 << "UNLOCK TABLES; \n"

puts "Acabou!"





