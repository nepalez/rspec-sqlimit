# ActiveRecord::Migration['5.0'] syntax is not supported prior to Rails 5.0
# This snippet supports it on Rails 4.2
unless ActiveRecord::Migration.respond_to?(:[])
  class ActiveRecord::Migration
    class << self
      def [](_version)
        self
      end
    end
  end
end
