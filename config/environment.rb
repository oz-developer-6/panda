# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default)

# I18n
require "i18n"
I18n.load_path += Dir["#{__dir__}/../locales/*.yml"]
I18n.default_locale = :en

# Database
require_relative "database"

# Ensure migrations run before models load so Sequel can inspect table schemas
require "sequel/extensions/migration"
Sequel::Migrator.run(DB, File.expand_path("../db/migrate", __dir__))

# App files
require_relative "../app/services/base"
Dir["#{__dir__}/../app/**/*.rb"].sort.each { |f| require f }
