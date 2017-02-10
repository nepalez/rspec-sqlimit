require "active_record"
require "rspec"

module RSpec
  module SQLimit
    require_relative "sqlimit/counter"
    require_relative "sqlimit/reporter"
  end

  Matchers.define :exceed_query_limit do |expected, matcher = nil|
    def counter
      @counter ||= RSpec::SQLimit::Counter.new
    end

    def message(expected, matcher, negation = false)
      if matcher
        condition   = negation ? "maximum" : "more than"
        restriction = " that match #{matcher}"
        suffix      = " among others (see mark ->)"
      end

      reporter = RSpec::SQLimit::Reporter.new(counter, matcher)

      <<-MESSAGE.gsub(/ +\|/, "")
        |Expected to run #{condition} #{expected} queries#{restriction}
        |The following #{reporter.count} queries were invoked#{suffix}:
        |#{reporter.lines.join("\n")}
      MESSAGE
    end

    match do |block|
      counter.count(&block)
      RSpec::SQLimit::Reporter.new(counter, matcher).count > expected
    end

    match_when_negated do |block|
      counter.count(&block)
      RSpec::SQLimit::Reporter.new(counter, matcher).count <= expected
    end

    failure_message do |_|
      message(expected, matcher)
    end

    failure_message_when_negated do |_|
      message(expected, matcher, true)
    end

    supports_block_expectations
  end
end
