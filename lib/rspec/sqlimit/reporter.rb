module RSpec::SQLimit
  class Reporter
    attr_reader :matcher

    def initialize(counter)
      @counter = counter
      @count   = counter.count
      @queries = counter.queries
      @matcher = counter.matcher
    end

    def call
      suffix = " among others (see mark ->)" if @matcher

      return "No queries were invoked" if @queries.empty?

      <<-MESSAGE.gsub(/ +\|/, "")
        |The following #{@count} queries were invoked#{suffix}:
        |#{lines.join("\n")}
      MESSAGE
    end

    private

    def lines
      @queries.map.with_index { |*args| line(*args) }
    end

    def line(query, index)
      prefix = (matcher && query[:sql] =~ matcher) ? "->" : "  "
      binds = query[:binds].any? ? "; #{query[:binds]} " : ""
      "#{prefix} #{index + 1}) #{query[:sql]}#{binds}" \
      " (#{query[:duration].round(3)} ms)"
    end
  end
end
