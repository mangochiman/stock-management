class CreatePriceHistories < ActiveRecord::Migration
  def change
    create_table :price_histories, :primary_key => :price_history_id do |t|
      t.integer :product_id
      t.float :price
      t.date :start_date
      t.date :end_date
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps null: false
    end
  end
end
