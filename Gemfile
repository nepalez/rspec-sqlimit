source "https://rubygems.org"

gemspec

group :test do
  gem "database_cleaner", ">= 1.5"
end

group :test, :development do
  gem "debug" unless ENV["CI"] == "true"
  gem "rails"
  gem "rake", ">= 10"
  gem "rubocop"
  gem "sqlite3", ">= 1.3"
end
