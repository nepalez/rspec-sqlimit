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

  Matchers.define :exceed_query_limits do |options|
    match do |block|
      @results = []
      options.each_pair do |key, expected|
        matcher = key == :total ? nil : Regexp.new("^#{key.to_s.upcase.gsub(/_/, " ")}")
        counter = RSpec::SQLimit::Counter[matcher, block]
        @results << ExceedQueryLimitsResult.new(counter, expected)
      end
      @results.any?(&:more_than_expected?)
    end

    failure_message do
      @results.select(&:less_than_expected?).first.message
    end

    failure_message_when_negated do
      @results.select(&:more_than_expected?).first.negated_message
    end

    supports_block_expectations
  end
  
  private
  class ExceedQueryLimitsResult
    attr_reader :counter
    attr_reader :expected
    def initialize counter, expected
      @counter = counter
      @expected = expected
    end

    def more_than_expected?
      @counter.count > expected
    end

    def less_than_expected?
      @counter.count <= expected
    end

    def negated_message
      message true
    end

    def message(negation = false)
      reporter    = RSpec::SQLimit::Reporter.new(@counter)
      condition   = negation ? "maximum" : "more than"
      restriction = " that match #{reporter.matcher}" if reporter.matcher

      <<-MESSAGE.gsub(/ +\|/, "")
        |Expected to run #{condition} #{@expected} queries#{restriction}
        |#{reporter.call}
      MESSAGE
    end
  end

end
