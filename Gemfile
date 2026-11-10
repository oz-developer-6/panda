# frozen_string_literal: true

source "https://rubygems.org"

ruby ">= 3.1", "< 5"

gem "roda", "~> 3.8"
gem "sequel", "~> 5.80"
gem "sqlite3", ">= 2.0"
gem "puma", "~> 6.4"
gem "i18n", "~> 1.14"
gem "rake"
gem "activesupport", "~> 7.1"

group :test do
  gem "rspec", "~> 3.13"
  gem "rack-test", "~> 2.1"
  gem "database_cleaner-sequel", "~> 2.0"
  gem "timecop", "~> 0.9"
end

group :development, :test do
  gem "pry", "~> 0.14"
end
