class CreateProductCategories < ActiveRecord::Migration
  def change
    create_table :product_categories, :primary_key => :product_category_id do |t|
      t.integer :product_id
      t.integer :category_id
      t.timestamps null: false
    end
  end
end
