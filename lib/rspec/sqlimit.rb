require "active_record"
require "rspec"

module RSpec::SQLimit
  require_relative "sqlimit/counter"
end

RSpec::Matchers.define :exceed_query_limit do
  match do |block|
  end
end
