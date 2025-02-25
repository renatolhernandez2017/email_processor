namespace :db do
  desc "Force drop the database by killing all connections"
  task force_drop: :environment do
    config = Rails.configuration.database_configuration[Rails.env]
    db_name = config["database"]
    user = config["username"]

    sql = "SELECT pg_terminate_backend(pg_stat_activity.pid)
           FROM pg_stat_activity
           WHERE pg_stat_activity.datname = '#{db_name}'
             AND pid <> pg_backend_pid();"

    ActiveRecord::Base.connection.execute(sql)
    Rake::Task["db:drop"].invoke
  end
end
