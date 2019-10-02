require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"

# Adds dummy:db tasks.
load "spec/dummy/Rakefile"

# Declares gem's own tasks.
desc "Runs test suite over all rails versions."
task :default do
  if ENV["BUNDLE_GEMFILE"] =~ /gemfiles/
    Rake::Task["dummy:db:create"].reenable
    Rake::Task["dummy:db:migrate"].reenable
    Rake::Task[:spec].invoke
  else
    Rake::Task[:appraise].invoke
  end
end

desc "Runs test suite."
task default: %w[dummy:db:create dummy:db:migrate] do
  exec "bundle exec rspec spec"
  exec "bundle exec rubocop"
end

task :appraise do
  exec "appraisal install && appraisal rake"
end
