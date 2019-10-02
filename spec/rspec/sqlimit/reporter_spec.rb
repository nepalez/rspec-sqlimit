require "spec_helper"

describe RSpec::SQLimit::Reporter do
  subject { described_class.new(counter) }

  context "no params were passed to the query" do
    let(:counter) { RSpec::SQLimit::Counter[/CREATE/, proc{ User.create }] }

    it "doesn't print binds" do
      # INSERT INTO "users" DEFAULT VALUES (0.284 ms)
      expect(subject.call).to include("DEFAULT VALUES")
    end
  end

  context "query contains params" do
    context "nil was passed as param" do
      let(:counter) do
        RSpec::SQLimit::Counter[/CREATE/, proc { User.create(id: nil) }]
      end

      it "doesn't print binds" do
        # INSERT INTO "users" DEFAULT VALUES (0.284 ms)
        expect(subject.call).to include("DEFAULT VALUES")
      end
    end

    context "single param was passed" do
      let(:counter) do
        RSpec::SQLimit::Counter[/CREATE/, proc { User.create(id: 1) }]
      end

      it "prints param as an array with one element" do
        # INSERT INTO "users" ("id") VALUES (?); [1]  (0.234 ms)
        expect(subject.call).to include("VALUES (?); [1]")
      end
    end

    context "array was passed as a param" do
      let(:counter) do
        RSpec::SQLimit::Counter[
          /SELECT/, proc { User.where(id: [1, 2, 3]).to_a }
        ]
      end

      it "prints all params" do
        # rubocop: disable Metrics/LineLength
        # SELECT "users".* FROM "users" WHERE "users"."id" IN (1, 2, 3) (0.17 ms))
        # Rails >= 6:
        # SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?, ?); [1, 2, 3]  (0.121 ms)
        # rubocop: enable Metrics/LineLength
        expect(subject.call).to include("1, 2, 3")
      end
    end
  end

  context "activerecord query caching was enabled" do
    let(:counter) do
      RSpec::SQLimit::Counter[/SELECT "users"/, proc { queries }]
    end

    let(:queries) do
      User.cache do
        User.where(id: 1).to_a
        User.where(id: 1).to_a
        User.where(id: [2, 3]).to_a
        User.where(id: [2, 3]).to_a
      end
    end

    it "ignores cached queries" do
      expect(subject.call).to include("2 queries were invoked")
    end
  end
end
