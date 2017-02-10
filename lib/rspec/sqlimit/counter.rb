module RSpec::SQLimit
  class Counter
    attr_reader :queries

    def initialize
      @queries = []
    end

    # FIXME add mutex to ensure thread-safety
    def count
      @queries = []
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        yield
      end
    end

    private

    def callback
      @callback ||= lambda(_name, start, finish, _message_id, values) do
        return if %w(CACHE SCHEMA).include? values[:name]
        queries << { sql: values[:sql], duration: (finish - start) * 1_000 }
      end
    end
  end
end
