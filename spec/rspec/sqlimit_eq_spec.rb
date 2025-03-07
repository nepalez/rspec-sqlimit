require "spec_helper"

describe "exceed_query_limit" do
  context "without restrictions" do
    it "works when no queries are made" do
      expect { User.new }.to equal_query_limit(0)
    end

    it "works when nil is used as a parameter" do
      expect { User.create id: nil }.to equal_query_limit(3)
    end

    it "works when array is used as a restriction" do
      expect { (User.where id: [1, 2, 3]).to_a }.to equal_query_limit(1)
    end

    it "works when actual number of queries is equal limit" do
      expect { User.create }.to equal_query_limit(3)
    end

    it "works when actual number of queries exceeds the limit" do
      expect { User.create }.not_to equal_query_limit(2)
    end
  end

  context "with a restriction" do
    it "works when no queries are made" do
      expect { User.new }.to equal_query_limit(0).with(/INSERT/)
    end

    it "works when nil is used as a parameter" do
      expect { User.create id: nil }.to equal_query_limit(1).with(/INSERT/)
    end

    it "works when array is used as a restriction" do
      expect { (User.where id: [1, 2, 3]).to_a }
        .to equal_query_limit(1)
        .with(/SELECT/)
    end

    it "works when actual number of queries is equal limit" do
      expect { User.create }.to equal_query_limit(1).with(/INSERT/)
    end

    it "works when actual number of queries exceeds the limit" do
      expect { User.create id: 3 }.to equal_query_limit(1).with(/INSERT/)
    end
  end
end
