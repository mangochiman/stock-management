class CreateStockItems < ActiveRecord::Migration
  def change
    create_table :stock_items, :primary_key => :stock_item_id do |t|
      t.integer :stock_id
      t.integer :product_id
      t.integer :shots_sold
      t.integer :damaged_stock
      t.integer :complementary_stock
      t.integer :closing_stock
      t.integer :opening_stock
      t.timestamps null: false
    end
  end
end
