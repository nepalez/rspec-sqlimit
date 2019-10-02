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
        return if %w(CACHE SCHEMA).include? values[:name]
        return if cached_query?(values)
        queries << {
          sql: values[:sql],
          duration: (finish - start) * 1_000,
          binds: values[:type_casted_binds] || type_cast(values[:binds])
        }
      end
    end

    def type_cast(binds)
      binds.map { |column, value| ActiveRecord::Base.connection.type_cast(value, column) }
    end

    def cached_query?(values)
      values[:type_casted_binds].respond_to?(:call)
    end
  end
end
