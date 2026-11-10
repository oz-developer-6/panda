# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default)
require "sequel/extensions/migration"

db_url = ENV.fetch("DATABASE_URL", "sqlite://./db/panda.sqlite3")
DB = Sequel.connect(db_url)
DB.extension(:date_arithmetic)
DB.run("PRAGMA journal_mode=WAL") if db_url.start_with?("sqlite")

namespace :db do
  task :migrate do
    Sequel::Migrator.run(DB, "db/migrate")
    puts "Migrations complete"
  end

  task :reset do
    DB.tables.each { |t| DB.drop_table(t) }
    Sequel::Migrator.run(DB, "db/migrate")
    puts "Database reset"
  end

  task :schema_dump do
    require "sequel/extensions/schema_dumper"
    DB.extension :schema_dumper
    schema_content = "# frozen_string_literal: true\n\n#{DB.dump_schema_migration}"
    File.write("db/schema.rb", schema_content)
    puts "Schema dumped to db/schema.rb"
  end
end

task default: "db:migrate"
