Gem::Specification.new do |gem|
  gem.name        = "rspec-sqlimit"
  gem.version     = "0.0.1"
  gem.author      = "Andrew Kozin (nepalez)"
  gem.email       = "andrew.kozin@gmail.com"
  gem.homepage    = "https://github.com/nepalez/rspec-sqlimit"
  gem.summary     = "RSpec matcher to control SQL queries made by block of code"
  gem.license     = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]

  gem.required_ruby_version = ">= 2.3"

  gem.add_runtime_dependency "activerecord", "> 4.0", "< 6.0"
  gem.add_runtime_dependency "rspec", "~> 3.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rubocop", "~> 0.44"
end
