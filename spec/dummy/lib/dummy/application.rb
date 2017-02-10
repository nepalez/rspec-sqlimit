module Dummy
  class Application
    class << self
      # Configuration settings wrapper for the
      # <tt>ActiveRecord::Tasks::DatabaseTasks</tt>.
      #
      # Establishes AR connection after configuration.
      #
      def configure
        yield tasks
        base.configurations = tasks.database_configuration
        base.establish_connection(tasks.env)
      end

      private

      def base
        @base ||= ActiveRecord::Base
      end

      def tasks
        @tasks ||= ActiveRecord::Tasks::DatabaseTasks
      end
    end
  end
end
