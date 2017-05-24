module RSpec::SQLimit
  class Counter
    attr_reader :queries, :matcher

    def self.[](*args)
      new(*args).tap(&:call)
    end

    def initialize(matcher, block)
      @queries = []
      @matcher = matcher
      @block   = block
      @mutex   = Mutex.new
    end

    def call
      @mutex.synchronize do
        @queries = []
        ActiveSupport::Notifications.subscribed callback, "sql.active_record" do
          @block.call
        end
      end
    end

    def count
      matcher ? queries.count { |query| query[:sql] =~ matcher } : queries.count
    end

    private

    def callback
      @callback ||= lambda do |_name, start, finish, _message_id, values|
        return if %w[CACHE SCHEMA].include? values[:name]
        queries << { sql: bind_arguments_to_query(values[:sql], values[:binds]),
                     duration: (finish - start) * 1_000 }
      end
    end

    def bind_arguments_to_query(sql, args)
      result = sql
      args.each do |arg|
        result = result.sub("?", %("#{arg.value}"))
      end
      result
    end
  end
end
