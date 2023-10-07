require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"

# Adds dummy:db tasks.
load "spec/dummy/Rakefile"

desc "Runs test suite."
task default: %w[db:reset db:schema:load] do
  exec "bundle exec rspec spec"
end
