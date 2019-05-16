class CreateProductAdditions < ActiveRecord::Migration
  def change
    create_table :product_additions, :primary_key => :product_addition_id do |t|
      t.integer :product_id
      t.date :date_added
      t.integer :added_stock
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps null: false
    end
  end
end
