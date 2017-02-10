class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :users
      t.string     :title
      t.text       :text
    end
  end
end
