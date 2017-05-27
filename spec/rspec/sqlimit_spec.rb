require "spec_helper"

describe "exceed_query_limit" do
  context "without restrictions" do
    it "works when no queries are made" do
      expect { User.new }.not_to exceed_query_limit(0)
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

    it "works when actual number of queries is below the limit" do
      expect { User.create }.not_to exceed_query_limit(1).with(/INSERT/)
    end

    it "works when actual number of queries exceeds the limit" do
      expect { User.create id: 3 }.to exceed_query_limit(0).with(/INSERT/)
    end

    it 'works when nil is used' do
      expect { User.create id: nil }.to exceed_query_limit(0).with(/INSERT/)
    end
  end
end
