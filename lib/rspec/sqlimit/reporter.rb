module RSpec::SQLimit
  class Reporter
    attr_reader :matcher

    def initialize(counter, matcher = nil)
      @counter = counter
      @matcher = matcher
    end

    def count
      return queries.count unless @matcher
      queries.count { |query| query[:sql] =~ @matcher }
    end

    def lines
      queries.map.with_index { |*args| line(*args) }
    end

    private

    def line(query, index)
      prefix = @matcher && query =~ @matcher ? "->" : "  "
      "#{prefix} #{index}) #{query[:sql]} (#{query[:duration].round(3)} ms)"
    end

    def queries
      @queries ||= @counter.queries
    end
  end
end
