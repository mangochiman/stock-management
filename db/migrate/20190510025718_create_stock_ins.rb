class CreateStockIns < ActiveRecord::Migration
  def change
    create_table :stock_ins, :primary_key => :stock_in_id do |t|
      t.integer :product_id
      t.integer :quantity
      t.date :date_in
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps null: false
    end
  end
end
