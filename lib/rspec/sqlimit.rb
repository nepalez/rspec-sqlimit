require "active_support/notifications"
require "active_record"
require "rspec"

module RSpec
  module SQLimit
    require_relative "sqlimit/counter"
    require_relative "sqlimit/reporter"
  end

  Matchers.define :exceed_query_limit do |expected|
    chain :with do |matcher|
      @matcher = matcher
    end

    match do |block|
      @counter ||= RSpec::SQLimit::Counter[@matcher, block]
      @counter.count > expected
    end

    match_when_negated do |block|
      @counter ||= RSpec::SQLimit::Counter[@matcher, block]
      @counter.count <= expected
    end

    failure_message do |_|
      message(expected, @counter)
    end

    failure_message_when_negated do |_|
      message(expected, @counter, true)
    end

    supports_block_expectations

    def message(expected, counter, negation = false)
      reporter    = RSpec::SQLimit::Reporter.new(counter)
      condition   = negation ? "maximum" : "more than"
      restriction = " that match #{reporter.matcher}" if reporter.matcher

      <<-MESSAGE.gsub(/ +\|/, "")
        |Expected to run #{condition} #{expected} queries#{restriction}
        |#{reporter.call}
      MESSAGE
    end
  end
end
