class CreateStockCards < ActiveRecord::Migration
  def change
    create_table :stock_cards, :primary_key => :stock_card_id do |t|
      t.integer :product_id
      t.integer :opening_stock
      t.integer :added_stock
      t.integer :closing_stock
      t.date :date
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps null: false
    end
  end
end
