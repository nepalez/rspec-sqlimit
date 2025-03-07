Gem::Specification.new do |gem|
  gem.name        = "rspec-sqlimit"
  gem.version     = "0.0.6"
  gem.author      = "Andrew Kozin (nepalez)"
  gem.email       = "andrew.kozin@gmail.com"
  gem.homepage    = "https://github.com/nepalez/rspec-sqlimit"
  gem.summary     = "RSpec matcher to control SQL queries made by block of code"
  gem.license     = "MIT"

  gem.files            = Dir.glob("lib/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]

  gem.required_ruby_version = ">= 2.3"

  gem.add_dependency "activerecord", ">= 4.2.0"
  gem.add_dependency "rspec", "~> 3.0"
end
