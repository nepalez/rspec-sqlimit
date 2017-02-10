require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"

# Adds dummy:db tasks.
load "spec/dummy/Rakefile"

# Declares gem's own tasks.
desc "Runs test suite."
task default: %w(dummy:db:migrate) do
  system "bundle exec rspec spec"
end
