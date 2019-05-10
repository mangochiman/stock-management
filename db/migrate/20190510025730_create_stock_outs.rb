class CreateStockOuts < ActiveRecord::Migration
  def change
    create_table :stock_outs, :primary_key => :stock_out_id do |t|
      t.integer :product_id
      t.integer :quantity
      t.date :date_out
      t.string :reason
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps null: false
    end
  end
end
