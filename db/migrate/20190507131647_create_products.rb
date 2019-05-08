class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, :primary_key => :product_id do |t|
      t.string :name
      t.string :label
      t.string :part_number
      t.integer :minimum_required
      t.integer :starting_inventory
      t.integer :inventory_on_hand
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps null: false
    end
  end
end
