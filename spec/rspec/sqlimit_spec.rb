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

    context 'for collection' do
      before do
        3.times { User.create }
      end
      it 'works when actual number of queries exceeds the limit' do
        expect { User.all.to_a }.to exceed_query_limit(0).with(/SELECT/)
      end

      it 'works when actual number of queries is below the limit' do
        expect { User.all.to_a }.not_to exceed_query_limit(1).with(/SELECT/)
      end

      it 'works when array is used as a restrcition' do
        expect { User.where(id: [1, 2, 3]).to_a }.to exceed_query_limit(0)
                                                         .with(/SELECT/)
      end

      it 'works when array is used as a restrcition negative case' do
        expect { User.where(id: [1, 2, 3]).to_a }.not_to exceed_query_limit(1)
                                                         .with(/SELECT/)
      end
    end

    context 'update or delete queries' do
      let(:user) { User.create }
      describe '.update' do
        it 'works when actual number of queries is exceeds the limit' do
          expect { user.update(id: 2) }.to exceed_query_limit(0).with(/UPDATE/)
        end

        it 'works when actual number of queries is below the limit' do
          expect { user.update(id: 2) }.not_to exceed_query_limit(1)
                                                   .with(/UPDATE/)
        end
      end

      describe '.destroy' do
        it 'works when actual number of queries is below the limit' do
          expect { user.destroy }.not_to exceed_query_limit(0).with(/UPDATE/)
        end
      end
    end
  end
end
