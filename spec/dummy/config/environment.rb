Dummy::Application.configure do |config|
  dummy        = File.expand_path "../..", __FILE__
  database_yml = File.join(dummy, "config/database.yml")

  config.database_configuration = YAML.load File.read(database_yml)
  config.db_dir                 = File.join(dummy, "db")
  config.env                    = :test
  config.migrations_paths       = [File.join(dummy, "db/migrate")]
  config.root                   = dummy
end
