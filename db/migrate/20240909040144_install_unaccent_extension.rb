class InstallUnaccentExtension < ActiveRecord::Migration[7.1]
  # Instala o extensão unaccent do postgresql https://www.postgresql.org/docs/current/static/unaccent.html
  #
  # Para instalar localmente:
  # 1. Instalar o postgresql-contrib:
  #    Linux: sudo apt-get install postgresql-contrib
  #    Mac: instalado por default pelo homebrew
  #
  # 2. Para criar extensão é necessário que o usuário do psql seja SUPERUSER
  #    sudo -u postgres psql postgres
  #    ALTER USER mydb_user WITH SUPERUSER;
  #
  # 3. Caso a migration já tenha rodado, usar o rails dbconsole
  #    para executar
  #    CREATE EXTENSION IF NOT EXISTS unaccent;

  def up
    execute "CREATE EXTENSION IF NOT EXISTS unaccent;"
  end

  def down
    execute "DROP EXTENSION IF EXISTS unaccent;"
  end
end
