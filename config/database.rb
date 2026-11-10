# frozen_string_literal: true

db_url = ENV.fetch("DATABASE_URL", "sqlite://./db/panda.sqlite3")
DB = Sequel.connect(db_url)
DB.extension(:date_arithmetic) # this is also important, because this way we can swap the databse without worrying about datetime
# Enable SQLite WAL, this will make it allow to read and write for the application, so it wont block the other bits, when writing or reading
DB.run("PRAGMA journal_mode=WAL") if db_url.start_with?("sqlite") # I have used the db_url here, but this could be controlled via env var
