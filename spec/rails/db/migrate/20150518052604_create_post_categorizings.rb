class CreatePostCategorizings < ActiveRecord::Migration
  def change
    create_table :post_categorizings do |t|
      t.belongs_to :post, index: true, foreign_key: true
      t.belongs_to :category, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
