require "spec_helper"

describe "exceed_query_limit" do
  context "without restrictions" do
    it "works when no queries are made" do
      expect { User.new }.not_to exceed_query_limit(0)
    end

    it "works when nil is used as a parameter" do
      expect { User.create id: nil }.to exceed_query_limit(0)
    end

    it "works when array is used as a restriction" do
      expect { (User.where id: [1, 2, 3]).to_a }.to exceed_query_limit(0)
    end

    it "works when actual number of queries is below the limit" do
      expect { User.create }.not_to exceed_query_limit(3)
    end

    it "works when actual number of queries exceeds the limit" do
      expect { User.create }.to exceed_query_limit(2)
    end
  end

  context "with a restriction" do
    it "works when no queries are made" do
      expect { User.new }.not_to exceed_query_limit(0).with(/INSERT/)
    end

    it "works when nil is used as a parameter" do
      expect { User.create id: nil }.to exceed_query_limit(0).with(/INSERT/)
    end

    it "works when array is used as a restriction" do
      expect { (User.where id: [1, 2, 3]).to_a }.to exceed_query_limit(0).with(/SELECT/)
    end

    it "works when actual number of queries is below the limit" do
      expect { User.create }.not_to exceed_query_limit(1).with(/INSERT/)
    end

    it "works when actual number of queries exceeds the limit" do
      expect { User.create id: 3 }.to exceed_query_limit(0).with(/INSERT/)
    end
  end
end

describe "#exceed_query_limits" do
  let(:select_sql) { "SELECT * FROM Users" }
  let(:delete_sql) { "DELETE FROM Users WHERE id = 42" }
  let(:update_sql) { "UPDATE Users SET id = 42 WHERE id = 0" }

  context "not negated" do
    it "works with single queries" do
      expect { User.create id: nil }.to exceed_query_limits(
        insert: 0
      )
    end

    [
      { delete: 0, select: 2 },
      { delete: 1, select: 1 },
      { delete: 0, select: 1, total: 3 }
    ].each do |limits|
      it "works when the limits are #{limits} and the queries are SELECT, DELETE, SELECT" do
        expect do
          ActiveRecord::Base.connection.execute(select_sql)
          ActiveRecord::Base.connection.execute(delete_sql)
          ActiveRecord::Base.connection.execute(select_sql)
        end.to exceed_query_limits(limits)
      end
    end
  end

  context "negated" do
    it "works with single queries" do
      expect { User.create id: nil }.not_to exceed_query_limits(
        insert: 1
      )
    end

    it "works when the limit is { 2 SELECT, 1 DELETE, 3 total } and the calls are SELECT, DELETE, SELECT" do
      expect do
        ActiveRecord::Base.connection.execute(select_sql)
        ActiveRecord::Base.connection.execute(delete_sql)
        ActiveRecord::Base.connection.execute(select_sql)
      end.not_to exceed_query_limits(
        delete: 1,
        select: 2,
        total: 3
      )
    end

    it "works when the limit is { 2 SELECT, 1 DELETE, 4 total } and the calls are SELECT, DELETE, SELECT, UPDATE" do
      expect do
        ActiveRecord::Base.connection.execute(select_sql)
        ActiveRecord::Base.connection.execute(delete_sql)
        ActiveRecord::Base.connection.execute(select_sql)
        ActiveRecord::Base.connection.execute(update_sql)
      end.not_to exceed_query_limits(
        delete: 1,
        select: 2,
        total: 4
      )
    end

    it "works when the limit is { 2 SELECT, 1 DELETE, 4 total } and the calls are SELECT, SELECT, UPDATE" do
      p exceed_query_limits.method(:matches?).source_location
      expect do
        ActiveRecord::Base.connection.execute(select_sql)
        ActiveRecord::Base.connection.execute(select_sql)
        ActiveRecord::Base.connection.execute(update_sql)
      end.not_to exceed_query_limits(
        delete: 1,
        select: 2,
        total: 4
      )
    end
  end
end
