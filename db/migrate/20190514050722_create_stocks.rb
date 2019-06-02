class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks, :primary_key => :stock_id do |t|
      t.integer :user_id
      t.datetime :stock_time
      t.float :amount_collected
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps null: false
    end
  end
end
